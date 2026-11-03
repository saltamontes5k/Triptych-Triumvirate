// NMS script windows (arcade) -- client half. See nms_window.h.
#include "nms_window.h"

#include "MQ2Main.h"
#include "MQ2Globals.h"
#include "MQ2Internal.h"
#include "RenderHooks.h"

#include <dinput.h>

#include <algorithm>
#include <cstring>

using CXWnd = EQClasses::CXWnd;

namespace {

// CXWnd::Location lives at 0x60 (EQUIStructs.h CXWnd block); drag updates the
// same field, so writing it is consistent with native window movement.
RECT& WndRect(CXWnd* w) { return *reinterpret_cast<RECT*>(reinterpret_cast<char*>(w) + 0x60); }

// little-endian reader
class Rd {
public:
	Rd(const uint8_t* d, const uint8_t* e) : m_d(d), m_e(e) {}
	bool Ok(size_t n) const { return m_d + n <= m_e; }
	bool Done() const { return m_d >= m_e; }
	uint8_t U8() { return *m_d++; }
	uint16_t U16() { uint16_t v = m_d[0] | (m_d[1] << 8); m_d += 2; return v; }
	uint32_t U32() { uint32_t v = m_d[0] | (m_d[1] << 8) | (m_d[2] << 16) | (uint32_t(m_d[3]) << 24); m_d += 4; return v; }
	int16_t I16() { return static_cast<int16_t>(U16()); }
	float F32() { uint32_t b = U32(); float f; memcpy(&f, &b, 4); return f; }
	std::string Str()
	{
		uint16_t n = U16();
		if (!Ok(n)) { m_d = m_e; return std::string(); }
		std::string s(reinterpret_cast<const char*>(m_d), n);
		m_d += n;
		return s;
	}
	const uint8_t* p() const { return m_d; }
	const uint8_t* e() const { return m_e; }
	void skip(size_t n) { m_d += n; }

private:
	const uint8_t* m_d;
	const uint8_t* m_e;
};

const uint32_t MSG_OPEN = 1, MSG_CLOSE = 2, MSG_CLEAR = 3, MSG_WIDGET = 4, MSG_SETWID = 5, MSG_STYLE = 6, MSG_FRAME = 7, MSG_LOCALACTION = 8;


uint32_t ARGB(uint32_t a, uint32_t r, uint32_t g, uint32_t b) { return (a << 24) | (r << 16) | (g << 8) | b; }
D3DCOLOR Col(uint32_t argb) { return static_cast<D3DCOLOR>(argb); }

void BytesOut(std::vector<uint8_t>& v, uint32_t x) { v.push_back(x & 0xFF); v.push_back((x >> 8) & 0xFF); v.push_back((x >> 16) & 0xFF); v.push_back((x >> 24) & 0xFF); }

PMOUSEINFO GetMouse() { return EQADDR_MOUSE; }

// DIK -> NMSW key value / ascii, per the manual's kind-2 codes.
int MapKey(uint32_t dik, uint32_t& value)
{
	value = 0;
	switch (dik) {
		case DIK_UP: value = NMSW_KEY_UP; return 2;
		case DIK_DOWN: value = NMSW_KEY_DOWN; return 2;
		case DIK_LEFT: value = NMSW_KEY_LEFT; return 2;
		case DIK_RIGHT: value = NMSW_KEY_RIGHT; return 2;
		case DIK_SPACE: value = NMSW_KEY_SPACE; return 2;
		case DIK_RETURN: case DIK_NUMPADENTER: value = NMSW_KEY_ENTER; return 2;
		case DIK_ESCAPE: value = NMSW_KEY_ESCAPE; return 2;
		default: break;
	}

	// top-row digits 1..0
	if (dik >= DIK_1 && dik <= DIK_0) { value = (dik == DIK_0) ? '0' : ('1' + (dik - DIK_1)); return 1; }
	// letters (unshifted uppercase per the manual)
	if (dik >= DIK_Q && dik <= DIK_P) { value = 'Q' + (dik - DIK_Q); return 1; }
	if (dik >= DIK_A && dik <= DIK_L) { value = 'A' + (dik - DIK_A); return 1; }
	if (dik >= DIK_Z && dik <= DIK_M) { value = 'Z' + (dik - DIK_Z); return 1; }

	return 0;
}

// MSG_FRAME payload -> widget pieces
void ParseFramePieces(NMSWin::Widget& wgt, Rd& r)
{
	if (!r.Ok(2)) { r.skip(r.e() - r.p()); return; }
	uint16_t count = r.U16();

	wgt.pieces.clear();
	wgt.pieces.reserve(std::min<uint16_t>(count, 512));

	for (int i = 0; i < count && !r.Done(); i++) {
		if (!r.Ok(19)) break;
		NMSWin::Piece p;
		p.type = r.U8();
		p.x = r.I16();
		p.y = r.I16();
		p.a = r.I16();
		p.b = r.I16();
		p.argb = r.U32();
		p.aux = r.U16();
		p.aux2 = r.U16();
		p.aux3 = r.U16();

		switch (p.type) {
			case NMSWP_TEXT:
			case NMSWP_BANNER:
			case NMSWP_LABEL:
			case NMSWP_ICON:
				p.text = r.Str();
				break;
			case NMSWP_GRID: {
				if (!r.Ok(2)) break;
				uint16_t filled = r.U16();
				for (int k = 0; k < filled && r.Ok(6); k++) {
					uint16_t cell = r.U16();
					uint32_t argb = r.U32();
					p.grid.emplace_back(cell, argb);
				}
				break;
			}
			default:
				break;
		}

		wgt.pieces.push_back(std::move(p));
	}
}

} // namespace

namespace NMSWin {

// ---------------------------------------------------------------------------
// shell window: bare SIDL frame (drag via title bar); all content is d3d
// ---------------------------------------------------------------------------
class ArcadeShellWnd : public CCustomWnd {
public:
	ArcadeWindow* m_win = nullptr;
	CXWnd* m_close = nullptr;

	ArcadeShellWnd(ArcadeWindow* win) : CCustomWnd("NMS_ArcadeShell")
	{
		m_win = win;
		m_close = GetChildItem("NMSArcadeClose");
		if (m_close && (win->flags & NMSW_F_NOCLOSE)) {
			m_close->Show(false, true);
		}
		CXStr title(const_cast<char*>(win->title.c_str()));
		(reinterpret_cast<CXWnd*>(this))->SetWindowTextA(title);
		SetWndNotification(ArcadeShellWnd);
	}

	int WndNotification(CXWnd* pWnd, unsigned int Message, void* data)
	{
		if (Message == XWM_LCLICK) {
			if (m_close && pWnd == m_close) {
				Manager::Get().SendClosed(*m_win);
				return 1;
			}
			PMOUSEINFO m = EQADDR_MOUSE;
			Manager::Get().ClickWindow(*m_win, static_cast<int>(m->X), static_cast<int>(m->Y));
			return 1;
		}
		return CCustomWnd::WndNotification(pWnd, Message, data);
	}
};

Manager& Manager::Get()
{
	static Manager s_mgr;
	return s_mgr;
}

// ---------------------------------------------------------------------------
// packet parse (server nms_window.h documents the wire)
// ---------------------------------------------------------------------------
void Manager::OnPacket(void* buf, size_t size)
{
	if (!buf || size < 1) {
		return;
	}

	Rd r(static_cast<const uint8_t*>(buf), static_cast<const uint8_t*>(buf) + size);
	while (!r.Done()) {
		uint8_t msg = r.U8();
		switch (msg) {
			case MSG_OPEN: {
				if (!r.Ok(4)) return;
				uint32_t id = r.U32();
				std::string key = r.Str();
				std::string title = r.Str();
				if (!r.Ok(5)) return;
				uint16_t w = r.U16();
				uint16_t h = r.U16();
				uint8_t flags = r.U8();

				ArcadeWindow* win = nullptr;
				for (auto& e : m_wins) {
					if (e.id == id) { win = &e; break; }
				}
				if (!win) {
					for (auto& e : m_wins) {
						if (e.key == key) { win = &e; break; }
					}
				}
				if (!win) {
					m_wins.emplace_back();
					win = &m_wins.back();
					win->id = id;
					win->key = key;
				}
				win->title = title;
				win->w = w;
				win->h = h;
				win->flags = flags;
				win->relayout_needed = true;
				win->closed_event_sent = false;
				EnsureShell(*win);
				break;
			}
			case MSG_CLOSE: {
				if (!r.Ok(4)) return;
				uint32_t id = r.U32();
				for (auto it = m_wins.begin(); it != m_wins.end(); ++it) {
					if (it->id == id) {
						DestroyShell(*it);
						m_wins.erase(it);
						break;
					}
				}
				break;
			}
			case MSG_CLEAR: {
				if (!r.Ok(4)) return;
				uint32_t id = r.U32();
				for (auto& e : m_wins) {
					if (e.id == id) {
						e.widgets.clear();
						e.hits.clear();
						e.active_input = -1;
						e.relayout_needed = true;
					}
				}
				break;
			}
			case MSG_STYLE: {
				if (!r.Ok(14)) return;
				uint32_t id = r.U32();
				for (auto& e : m_wins) {
					if (e.id == id) {
						e.style_bg = r.U32();
						e.style_border = r.U32();
						e.style_rounding = r.U8();
						e.style_border_px = r.U8();
						e.relayout_needed = true;
					}
				}
				break;
			}
			case MSG_FRAME: {
				if (!r.Ok(6)) return;
				uint32_t id = r.U32();
				uint16_t idx = r.U16();
				bool parsed = false;
				for (auto& e : m_wins) {
					if (e.id == id && idx < e.widgets.size()) {
						ParseFramePieces(e.widgets[idx], r);
						e.relayout_needed = true;
						parsed = true;
						break;
					}
				}
				if (!parsed) {
					r.skip(r.e() - r.p());
				}
				break;
			}
			case MSG_LOCALACTION: {
				// server-driven local UI: action 1 = open the native bank window
				// (the Nautilus Vault panel's Bank button routes here)
				if (!r.Ok(6)) return;
				r.U32();
				uint16_t local_action = r.U16();
				if (local_action == 1 && ppBankWnd && *ppBankWnd) {
					(*ppBankWnd)->Activate((EQPlayer*)pLocalPlayer);
				}
				break;
			}
			case MSG_WIDGET:
			case MSG_SETWID: {
				if (!r.Ok(8)) return;
				uint32_t id = r.U32();
				uint16_t idx = r.U16();
				uint8_t kind = r.U8();
				uint8_t same = r.U8();

				ArcadeWindow* win = nullptr;
				for (auto& e : m_wins) {
					if (e.id == id) { win = &e; break; }
				}
				if (!win) {
					r.skip(r.e() - r.p());
					break;
				}
				if (msg == MSG_SETWID && idx >= win->widgets.size()) {
					r.skip(r.e() - r.p());
					break;
				}

				Widget wgt;
				wgt.kind = kind;
				wgt.same_line = same != 0;

				switch (kind) {
					case NMSW_HEADER:
					case NMSW_TEXT:
						if (!r.Ok(5)) return;
						wgt.argb = r.U32();
						wgt.wrap = r.U8() != 0;
						wgt.text = r.Str();
						break;
					case NMSW_SEP:
					case NMSW_SAMELINE:
						break;
					case NMSW_BUTTON:
						wgt.text = r.Str();
						if (!r.Ok(7)) return;
						wgt.argb = r.U32();
						wgt.action = r.U16();
						wgt.disabled = r.U8() != 0;
						break;
					case NMSW_TABLE: {
						if (!r.Ok(3)) return;
						wgt.cols = r.U8();
						uint16_t n = r.U16();
						for (int i = 0; i < n && !r.Done(); i++) {
							wgt.cells.push_back(r.Str());
						}
						break;
					}
					case NMSW_PROGRESS:
						if (!r.Ok(4)) return;
						wgt.fraction = r.F32();
						wgt.text = r.Str();
						break;
					case NMSW_INPUT:
						if (!r.Ok(3)) return;
						wgt.action = r.U16();
						wgt.size = r.U8();
						wgt.text = r.Str();
						break;
					case NMSW_ICON:
						if (!r.Ok(5)) return;
						wgt.icon_id = r.U32();
						wgt.size = r.U8();
						break;
					case NMSW_ITEMLINK:
						if (!r.Ok(4)) return;
						wgt.item_id = r.U32();
						wgt.text = r.Str();
						break;
					case NMSW_CANVAS:
						if (!r.Ok(4)) return;
						wgt.cw = r.U16();
						wgt.ch = r.U16();
						break;
					default:
						r.skip(r.e() - r.p());
						continue;
				}

				if (msg == MSG_SETWID) {
					// preserve layout/pieces from the existing widget
					Widget& old = win->widgets[idx];
					uint8_t old_kind = old.kind;
					std::vector<Piece> old_pieces = std::move(old.pieces);
					old = std::move(wgt);
					old.kind = old_kind;
					old.pieces = std::move(old_pieces);
				}
				else {
					if (idx > win->widgets.size()) {
						// out-of-order add: pad so indexes stay stable
						win->widgets.resize(idx);
					}
					win->widgets.push_back(std::move(wgt));
				}
				win->relayout_needed = true;
				break;
			}
			default:
				return; // unknown message: stop (stream desync guard)
		}
	}
}

// ---------------------------------------------------------------------------
// shell lifecycle
// ---------------------------------------------------------------------------
void Manager::EnsureShell(ArcadeWindow& win)
{
	if (win.shell) {
		return;
	}

	static bool xml_added = false;
	if (!xml_added) {
		::AddXMLFile("NMS_ArcadeWnd.xml");
		// latch the flag only when the template actually registered; a missing
		// file (UI not updated) must stay retryable on the next window open
		if (pSidlMgr->FindScreenPieceTemplate("NMS_ArcadeShell")) {
			xml_added = true;
		}
	}

	if (!pSidlMgr->FindScreenPieceTemplate("NMS_ArcadeShell")) {
		WriteChatf("[Arcade] Shell template missing -- the UI files are not updated.");
		return;
	}

	int open_count = static_cast<int>(m_wins.size());
	int cascade_x = 120 + (open_count % 6) * 48;
	int cascade_y = 100 + (open_count % 6) * 40;

	ArcadeShellWnd* shell = new ArcadeShellWnd(&win);
	win.shell = (CXWnd*)shell;
	win.close_btn = shell->m_close;

	// cascade: write the window rect directly (drag mutates the same field)
	RECT& rc = WndRect(win.shell);
	int w = rc.right - rc.left;
	int h = rc.bottom - rc.top;
	rc.left = cascade_x;
	rc.top = cascade_y;
	rc.right = cascade_x + w;
	rc.bottom = cascade_y + h;

	win.shell->Show(true, true);
	win.relayout_needed = true;
}

void Manager::DestroyShell(ArcadeWindow& win)
{
	if (!win.shell) {
		return;
	}
	ArcadeShellWnd* shell = (ArcadeShellWnd*)win.shell;
	win.shell = nullptr;
	win.close_btn = nullptr;
	(reinterpret_cast<CXWnd*>(shell))->Show(false, false);
	delete shell;
}

void Manager::SendClosed(ArcadeWindow& win)
{
	if (win.closed_event_sent) {
		return;
	}
	win.closed_event_sent = true;
	SendEvent(win.id, NMSW_EV_CLOSED, 0, 1, std::string());
	for (auto it = m_wins.begin(); it != m_wins.end(); ++it) {
		if (it->id == win.id) {
			DestroyShell(*it);
			m_wins.erase(it);
			break;
		}
	}
}

void Manager::SendEvent(uint32_t id, uint8_t kind, uint16_t action, uint32_t value, const std::string& text)
{
	std::vector<uint8_t> buf;
	buf.push_back(2);
	BytesOut(buf, id);
	buf.push_back(kind);
	buf.push_back(action & 0xFF);
	buf.push_back((action >> 8) & 0xFF);
	BytesOut(buf, value);
	buf.push_back(static_cast<uint8_t>(std::min<size_t>(128, text.size())));
	buf.insert(buf.end(), text.begin(), text.begin() + std::min<size_t>(128, text.size()));
	SendEQMessage(NMSW_OP_EVENT, buf.data(), static_cast<DWORD>(buf.size()));
}

void Manager::SendHello()
{
	if (m_hello_sent) {
		return;
	}
	m_hello_sent = true;

	std::vector<uint8_t> buf;
	buf.push_back(1);
	buf.push_back(NMSW_DLL_VERSION & 0xFF);
	buf.push_back((NMSW_DLL_VERSION >> 8) & 0xFF);
	BytesOut(buf, NMSW_CAP_WINDOWS);
	SendEQMessage(NMSW_OP_EVENT, buf.data(), static_cast<DWORD>(buf.size()));
	WriteChatf("[Arcade] announcing window support to the server (v%d)", NMSW_DLL_VERSION);
}

void Manager::OnGameState(DWORD state)
{
	if (state != GAMESTATE_INGAME) {
		for (auto& e : m_wins) {
			DestroyShell(e);
		}
		m_wins.clear();
		return;
	}

	// each zone process tracks window capability independently (WindowManager
	// lives in the zone), so re-announce on every zone-in -- the 9-byte hello
	// is cheap and idempotent server-side
	m_hello_sent = false;
	SendHello();
}

bool Manager::KeyCaptureActive() const
{
	for (const auto& e : m_wins) {
		if (e.shell && (e.flags & NMSW_F_CAPTUREKEYS)) {
			return true;
		}
	}
	return false;
}

// returns true when the key belongs to an open capture window (suppress it
// from the game); typing while an input is focused always suppresses
bool Manager::FeedKey(uint32_t dik, bool down)
{
	ArcadeWindow* capture = nullptr;
	for (auto& e : m_wins) {
		if (e.shell && (e.flags & NMSW_F_CAPTUREKEYS)) {
			capture = &e;
			break;
		}
	}
	if (!capture) {
		return false;
	}

	if (capture->active_input >= 0 && down) {
		// typing into an input box
		uint32_t value = 0;
		int kind = MapKey(dik, value);
		if (kind == 2 && value == NMSW_KEY_ENTER) {
			Widget& wgt = capture->widgets[capture->active_input];
			SendEvent(capture->id, NMSW_EV_INPUT, wgt.action, 0, capture->input_buffer);
			capture->input_buffer.clear();
			capture->active_input = -1;
			return true;
		}
		if (kind == 2 && value == NMSW_KEY_ESCAPE) {
			capture->input_buffer.clear();
			capture->active_input = -1;
			return true;
		}
		if (dik == DIK_BACK) {
			if (!capture->input_buffer.empty()) {
				capture->input_buffer.pop_back();
			}
			return true;
		}
		if (kind == 1 && capture->input_buffer.size() < capture->widgets[capture->active_input].size) {
			capture->input_buffer.push_back(static_cast<char>(value));
			return true;
		}
		return true; // swallow unhandled keys while typing
	}

	if (!down) {
		return false; // key-ups pass through, only presses fire events
	}

	uint32_t value = 0;
	int kind = MapKey(dik, value);
	if (!kind) {
		return false; // unrelated key (movement etc.) -> let the game have it
	}

	SendEvent(capture->id, NMSW_EV_KEY, 0, value, std::string());
	return true;
}

// ---------------------------------------------------------------------------
// hit testing
// ---------------------------------------------------------------------------
bool Manager::ClickWindow(ArcadeWindow& win, int sx, int sy)
{
	RECT& rc = WndRect(win.shell);
	int wx = sx - rc.left;
	int wy = sy - rc.top;

	// title-bar rows belong to the native chrome (drag etc.)
	if (wy < 24) {
		return false;
	}

	// iterate hits back-to-front (draw order)
	for (auto it = win.hits.rbegin(); it != win.hits.rend(); ++it) {
		const HitRegion& h = *it;
		if (wx >= h.x && wx < h.r && wy >= h.y && wy < h.b) {
			if (h.kind == NMSW_EV_CANVAS) {
				SendEvent(win.id, NMSW_EV_CANVAS, h.action, 0, std::string());
			}
			else if (h.kind == NMSW_EV_GRID) {
				int col = (std::max)(0, (wx - h.x) / (std::max)(1, h.cell_w));
				int row = (std::max)(0, (wy - h.y) / (std::max)(1, h.cell_h));
				int cell = row * (std::max)(1, static_cast<int>(h.grid_cols)) + col;
				SendEvent(win.id, NMSW_EV_GRID, h.action, static_cast<uint32_t>(cell), std::string());
			}
			else if (h.kind == NMSW_EV_BUTTON) {
				SendEvent(win.id, NMSW_EV_BUTTON, h.action, 0, std::string());
			}
			return true;
		}
	}

	// inputs: focus on click
	for (auto& wgt : win.widgets) {
		if (wgt.kind == NMSW_INPUT && wgt.placed &&
			wx >= wgt.lx && wx < wgt.lx + wgt.lw && wy >= wgt.ly && wy < wgt.ly + wgt.lh) {
			win.active_input = static_cast<int>(&wgt - win.widgets.data());
			win.input_buffer = wgt.text;
			return true;
		}
	}

	return true; // inside the shell: eat the click either way
}

// ---------------------------------------------------------------------------
// layout
// ---------------------------------------------------------------------------
void Manager::Relayout(ArcadeWindow& win)
{
	win.relayout_needed = false;
	win.hits.clear();

	if (!win.shell) {
		return;
	}

	RECT& rc = WndRect(win.shell);
	const int interior_w = (std::max)(50, static_cast<int>(rc.right - rc.left) - 12);
	const int pad = 6;

	int x = pad, y = 28; // below the native title bar
	int line_h = 0;

	for (auto& wgt : win.widgets) {
		wgt.placed = false;

		switch (wgt.kind) {
			case NMSW_SAMELINE:
				continue; // pure marker
			case NMSW_SEP:
				wgt.lx = pad; wgt.ly = y + line_h / 2; wgt.lw = interior_w - pad * 2; wgt.lh = 1;
				wgt.placed = true;
				y += line_h / 2 + 6;
				line_h = 0;
				continue;
			default:
				break;
		}

		int wgt_w = 0, wgt_h = 0;
		switch (wgt.kind) {
			case NMSW_HEADER:
				wgt_h = 22;
				wgt_w = TextWidth(wgt.text, 18);
				break;
			case NMSW_TEXT:
				if (wgt.wrap) {
					RECT calc = {0, 0, interior_w - pad * 2, 0};
					if (m_font14) {
						m_font14->DrawTextA(nullptr, wgt.text.c_str(), -1, &calc, DT_WORDBREAK | DT_CALCRECT, 0xFFFFFFFF);
					}
					wgt_w = interior_w - pad * 2;
					wgt_h = (std::max)(14, static_cast<int>(calc.bottom - calc.top));
				}
				else {
					wgt_w = TextWidth(wgt.text, 14);
					wgt_h = 16;
				}
				break;
			case NMSW_BUTTON:
				wgt_w = (std::max)(70, TextWidth(wgt.text, 14) + 20);
				wgt_h = 22;
				break;
			case NMSW_TABLE: {
				int cols = std::max<uint8_t>(1, wgt.cols);
				std::vector<int> colw(cols, 0);
				for (size_t i = 0; i < wgt.cells.size(); i++) {
					int c = static_cast<int>(i % cols);
					colw[c] = (std::max)(colw[c], TextWidth(wgt.cells[i], 14) + 12);
				}
				wgt_w = 0;
				for (int c = 0; c < cols; c++) {
					wgt_w += colw[c];
				}
				wgt_w = (std::min)(wgt_w, interior_w - pad * 2);
				wgt_h = 16 * static_cast<int>((wgt.cells.size() + cols - 1) / cols);
				break;
			}
			case NMSW_PROGRESS:
				wgt_w = interior_w - pad * 2;
				wgt_h = 16;
				break;
			case NMSW_INPUT:
				wgt_w = (std::max)(60, static_cast<int>(wgt.size) * 9 + 12);
				wgt_h = 18;
				break;
			case NMSW_ICON:
				wgt_w = wgt.size;
				wgt_h = wgt.size;
				break;
			case NMSW_ITEMLINK:
				wgt_w = TextWidth(wgt.text, 14);
				wgt_h = 16;
				break;
			case NMSW_CANVAS: {
				wgt_w = std::max<uint16_t>(wgt.cw, 40);
				wgt_h = std::max<uint16_t>(wgt.ch, 40);
				break;
			}
			default:
				wgt_w = 10;
				wgt_h = 10;
				break;
		}

		if (!wgt.same_line) {
			x = pad;
			y += line_h + 3;
			line_h = 0;
		}

		// clamp wide widgets to the interior
		if (wgt_w > interior_w - x - pad) {
			wgt_w = (std::max)(10, interior_w - x - pad);
		}

		wgt.lx = x;
		wgt.ly = y;
		wgt.lw = wgt_w;
		wgt.lh = wgt_h;
		wgt.placed = true;

		line_h = (std::max)(line_h, wgt_h);
		x += wgt_w + 6;

		// hit regions
		if (wgt.kind == NMSW_BUTTON && !wgt.disabled) {
			HitRegion h;
			h.x = wgt.lx; h.y = wgt.ly; h.r = wgt.lx + wgt.lw; h.b = wgt.ly + wgt.lh;
			h.kind = NMSW_EV_BUTTON;
			h.action = wgt.action;
			win.hits.push_back(h);
		}
		else if (wgt.kind == NMSW_ITEMLINK) {
			HitRegion h;
			h.x = wgt.lx; h.y = wgt.ly; h.r = wgt.lx + wgt.lw; h.b = wgt.ly + wgt.lh;
			h.kind = NMSW_EV_BUTTON;
			h.action = static_cast<uint16_t>(std::min<uint32_t>(0xFFFF, wgt.item_id));
			win.hits.push_back(h);
		}
				else if (wgt.kind == NMSW_CANVAS) {
					float hscale = 1.f;
					if (wgt.cw > 0 && wgt.ch > 0) {
						float sx = static_cast<float>(wgt.lw) / wgt.cw;
						float sy = static_cast<float>(wgt.lh) / wgt.ch;
						hscale = (std::min)(1.f, (std::min)(sx, sy));
					}

					for (const auto& p : wgt.pieces) {
						if (p.type == NMSWP_CLICKABLE) {
							HitRegion h;
							h.x = wgt.lx + static_cast<int>(p.x * hscale);
							h.y = wgt.ly + static_cast<int>(p.y * hscale);
							h.r = h.x + static_cast<int>(p.a * hscale);
							h.b = h.y + static_cast<int>(p.b * hscale);
							h.kind = NMSW_EV_CANVAS;
							h.action = p.aux;
							win.hits.push_back(h);
						}
						else if (p.type == NMSWP_GRID && p.aux3) {
							HitRegion h;
							h.x = wgt.lx + static_cast<int>(p.x * hscale);
							h.y = wgt.ly + static_cast<int>(p.y * hscale);
							h.r = h.x + static_cast<int>(p.a * p.aux * hscale);
							h.b = h.y + static_cast<int>(p.b * p.aux2 * hscale);
							h.kind = NMSW_EV_GRID;
							h.action = p.aux3;
							h.grid_cols = static_cast<uint8_t>(std::min<uint16_t>(255, p.aux));
							h.cell_w = (std::max)(1, static_cast<int>(p.a * hscale));
							h.cell_h = (std::max)(1, static_cast<int>(p.b * hscale));
							win.hits.push_back(h);
						}
					}
				}
	}
}

// ---------------------------------------------------------------------------
// d3d drawing
// ---------------------------------------------------------------------------
void Manager::KillDevice()
{
	if (m_white) { m_white->Release(); m_white = nullptr; }
	if (m_sprite) { m_sprite->Release(); m_sprite = nullptr; }
	if (m_line) { m_line->Release(); m_line = nullptr; }
	if (m_font14) { m_font14->Release(); m_font14 = nullptr; }
	if (m_font18) { m_font18->Release(); m_font18 = nullptr; }
	for (auto& kv : m_icon_tex) {
		if (kv.second) {
			kv.second->Release();
		}
	}
	m_icon_tex.clear();
	m_dev_ok = false;
	m_dev = nullptr;
}

// item icon art: <eqdir>\ItemIcons\<icon_id>.png (FloatingTextManager loads
// SpellIcons the same way). Missing files cache as nullptr so a partial pack
// degrades to the text fallback instead of rescanning the disk every frame.
IDirect3DTexture9* Manager::GetIconTexture(uint32_t icon_id) {
	auto it = m_icon_tex.find(icon_id);
	if (it != m_icon_tex.end()) {
		return it->second;
	}
	IDirect3DTexture9* tex = nullptr;
	if (m_dev_ok && m_dev) {
		char path[MAX_STRING];
		sprintf_s(path, sizeof(path), "%s\\ItemIcons\\%u.png", gszEQPath, icon_id);
		if (FAILED(D3DXCreateTextureFromFileExA(m_dev, path, D3DX_DEFAULT, D3DX_DEFAULT,
			1, 0, D3DFMT_UNKNOWN, D3DPOOL_MANAGED, D3DX_FILTER_NONE, D3DX_FILTER_NONE,
			0, NULL, NULL, &tex))) {
			tex = nullptr;
		}
	}
	m_icon_tex[icon_id] = tex;
	return tex;
}

void Manager::DrawIcon(int x, int y, int w, int h, uint32_t icon_id, const std::string& fallback_text) {
	IDirect3DTexture9* tex = GetIconTexture(icon_id);
	if (!tex || !m_sprite) {
		if (!fallback_text.empty() && m_sprite) {
			DrawTextStr(x + w / 2, y + (std::max)(0, (h - 14) / 2), fallback_text, 0xFFF2F2F2, 12, 1, w);
		}
		return;
	}
	D3DSURFACE_DESC desc;
	if (FAILED(tex->GetLevelDesc(0, &desc))) {
		return;
	}
	D3DXVECTOR2 scale(static_cast<float>(w) / static_cast<float>(desc.Width),
		static_cast<float>(h) / static_cast<float>(desc.Height));
	D3DXVECTOR2 trans(static_cast<float>(m_ofs_x + x), static_cast<float>(m_ofs_y + y));
	D3DXMATRIX mat;
	D3DXMatrixTransformation2D(&mat, NULL, 0.0f, &scale, NULL, 0.0f, &trans);
	m_sprite->SetTransform(&mat);
	m_sprite->Draw(tex, NULL, nullptr, nullptr, 0xFFFFFFFF);
	D3DXMatrixIdentity(&mat);
	m_sprite->SetTransform(&mat);
}

void Manager::FillRect(int x, int y, int w, int h, uint32_t argb)
{
	// this d3dx9's ID3DXSprite has no DrawTransform; tile sub-rects of a
	// 256x256 white texture instead (Draw draws the src rect 1:1)
	if (!m_sprite || !m_white || w <= 0 || h <= 0 || (argb >> 24) == 0) {
		return;
	}
	const int TILE = 256;
	for (int ty = 0; ty < h; ty += TILE) {
		for (int tx = 0; tx < w; tx += TILE) {
			RECT src = {0, 0, (std::min)(TILE, w - tx), (std::min)(TILE, h - ty)};
			D3DXVECTOR3 pos(static_cast<float>(m_ofs_x + x + tx), static_cast<float>(m_ofs_y + y + ty), 0.f);
			m_sprite->Draw(m_white, &src, nullptr, &pos, Col(argb));
		}
	}
}

void Manager::DrawLine(int x1, int y1, int x2, int y2, uint32_t argb, float width)
{
	if (!m_line || (argb >> 24) == 0) {
		return;
	}
	D3DXVECTOR2 v[2] = {
		D3DXVECTOR2(static_cast<float>(m_ofs_x + x1), static_cast<float>(m_ofs_y + y1)),
		D3DXVECTOR2(static_cast<float>(m_ofs_x + x2), static_cast<float>(m_ofs_y + y2))
	};
	m_line->SetWidth(width);
	m_line->Begin();
	m_line->Draw(v, 2, Col(argb));
	m_line->End();
}

void Manager::DrawRing(int cx, int cy, float radius, uint32_t argb, float width)
{
	const int SEG = 20;
	D3DXVECTOR2 v[SEG + 1];
	for (int i = 0; i <= SEG; i++) {
		float ang = 6.2831853f * i / SEG;
		v[i] = D3DXVECTOR2(
			static_cast<float>(m_ofs_x + cx) + cosf(ang) * radius,
			static_cast<float>(m_ofs_y + cy) + sinf(ang) * radius);
	}
	if (!m_line || (argb >> 24) == 0) {
		return;
	}
	m_line->SetWidth(width);
	m_line->Begin();
	m_line->Draw(v, SEG + 1, Col(argb));
	m_line->End();
}

int Manager::TextWidth(const std::string& s, int size)
{
	ID3DXFont* font = (size >= 17) ? m_font18 : m_font14;
	if (!font) {
		return static_cast<int>(s.size()) * 8;
	}
	RECT rc = {0, 0, 4000, 100};
	font->DrawTextA(nullptr, s.c_str(), -1, &rc, DT_CALCRECT | DT_NOPREFIX, 0xFFFFFFFF);
	return static_cast<int>(rc.right - rc.left);
}

void Manager::DrawTextStr(int x, int y, const std::string& s, uint32_t argb, int size, int align, int clip_w)
{
	ID3DXFont* font = (size >= 17) ? m_font18 : m_font14;
	if (!font || s.empty() || (argb >> 24) == 0) {
		return;
	}

	RECT rc;
	if (align == 1) {
		int w = TextWidth(s, size);
		rc.left = m_ofs_x + x - w / 2;
		rc.right = rc.left + w + 2;
	}
	else if (align == 2) {
		int w = TextWidth(s, size);
		rc.left = m_ofs_x + x - w;
		rc.right = rc.left + w + 2;
	}
	else {
		rc.left = m_ofs_x + x;
		rc.right = clip_w > 0 ? m_ofs_x + x + clip_w + 2 : m_ofs_x + x + TextWidth(s, size) + 2;
	}
	rc.top = m_ofs_y + y;
	rc.bottom = rc.top + size + 6;

	font->DrawTextA(m_sprite, s.c_str(), -1, &rc, DT_NOPREFIX | ((clip_w > 0) ? DT_END_ELLIPSIS : 0), Col(argb));
}

// ---------------------------------------------------------------------------
// render (EndScene hook)
// ---------------------------------------------------------------------------
void Manager::Render()
{
	if (m_wins.empty()) {
		return;
	}

	IDirect3DDevice9* dev = g_pDevice;
	if (!dev) {
		return;
	}

	if (dev != m_dev) {
		KillDevice();
		m_dev = dev;
	}

	if (!m_dev_ok) {
		HRESULT hr = D3DXCreateTexture(dev, 256, 256, 0, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, &m_white);
		if (FAILED(hr) || !m_white) {
			return;
		}
		D3DLOCKED_RECT lk;
		if (SUCCEEDED(m_white->LockRect(0, &lk, nullptr, 0))) {
			for (int y = 0; y < 256; y++) {
				uint32_t* row = reinterpret_cast<uint32_t*>(
					reinterpret_cast<uint8_t*>(lk.pBits) + static_cast<size_t>(y) * lk.Pitch);
				for (int x = 0; x < 256; x++) {
					row[x] = 0xFFFFFFFF;
				}
			}
			m_white->UnlockRect(0);
		}
		D3DXCreateSprite(dev, &m_sprite);
		D3DXCreateLine(dev, &m_line);
		D3DXCreateFontA(dev, 14, 0, FW_NORMAL, 0, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
			PROOF_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Arial", &m_font14);
		D3DXCreateFontA(dev, 18, 0, FW_BOLD, 0, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
			PROOF_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Arial", &m_font18);
		m_dev_ok = m_sprite && m_line && m_font14 && m_font18;
		if (!m_dev_ok) {
			return;
		}
	}

	if (!m_sprite) {
		return;
	}

	IDirect3DStateBlock9* state = nullptr;
	if (FAILED(dev->CreateStateBlock(D3DSBT_ALL, &state)) || !state) {
		return;
	}

	m_sprite->Begin(D3DXSPRITE_ALPHABLEND | D3DXSPRITE_DO_NOT_ADDREF_TEXTURE);

	for (auto& win : m_wins) {
		if (!win.shell) {
			continue; // shells are created on packet receipt, not per frame
		}
		if (win.relayout_needed) {
			Relayout(win);
		}

		RECT& rc = WndRect(win.shell);
		m_ofs_x = rc.left;
		m_ofs_y = rc.top;
		int interior_w = (std::max)(50, static_cast<int>(rc.right - rc.left) - 12);
		int interior_h = (std::max)(40, static_cast<int>(rc.bottom - rc.top) - 30);

		uint32_t bg = win.style_bg ? win.style_bg : ARGB(235, 18, 19, 30);
		uint32_t border = win.style_border ? win.style_border : ARGB(255, 196, 168, 96);

		FillRect(6, 24, interior_w, interior_h, bg);
		DrawLine(6, 24, 6 + interior_w, 24, border, 1.f);
		DrawLine(6, 24 + interior_h, 6 + interior_w, 24 + interior_h, border, 1.f);
		DrawLine(6, 24, 6, 24 + interior_h, border, 1.f);
		DrawLine(6 + interior_w, 24, 6 + interior_w, 24 + interior_h, border, 1.f);

		int piece_budget = 290;

		for (auto& wgt : win.widgets) {
			if (!wgt.placed) {
				continue;
			}

			switch (wgt.kind) {
				case NMSW_HEADER:
					DrawTextStr(wgt.lx, wgt.ly, wgt.text, wgt.argb ? wgt.argb : ARGB(255, 255, 215, 0), 18, 0, 0);
					break;
				case NMSW_TEXT:
					if (wgt.wrap) {
						RECT tr = {m_ofs_x + wgt.lx, m_ofs_y + wgt.ly,
							m_ofs_x + wgt.lx + wgt.lw, m_ofs_y + wgt.ly + wgt.lh + 2};
						m_font14->DrawTextA(m_sprite, wgt.text.c_str(), -1, &tr,
							DT_WORDBREAK | DT_NOPREFIX, Col(wgt.argb ? wgt.argb : 0xFFFFFFFF));
					}
					else {
						DrawTextStr(wgt.lx, wgt.ly, wgt.text, wgt.argb ? wgt.argb : 0xFFFFFFFF, 14, 0, wgt.lw);
					}
					break;
				case NMSW_SEP:
					FillRect(wgt.lx, wgt.ly, wgt.lw, 1, ARGB(160, 200, 200, 210));
					break;
				case NMSW_BUTTON: {
					uint32_t face = wgt.argb ? wgt.argb : ARGB(255, 46, 48, 66);
					if (wgt.disabled) {
						face = ARGB(140, 60, 60, 70);
					}
					FillRect(wgt.lx, wgt.ly, wgt.lw, wgt.lh, face);
					FillRect(wgt.lx, wgt.ly, wgt.lw, 1, ARGB(120, 255, 255, 255));
					uint32_t tcol = wgt.disabled ? ARGB(255, 150, 150, 150) : 0xFFFFFFFF;
					DrawTextStr(wgt.lx + wgt.lw / 2, wgt.ly + 3, wgt.text, tcol, 14, 1, 0);
					break;
				}
				case NMSW_TABLE: {
					int cols = std::max<uint8_t>(1, wgt.cols);
					int rows = static_cast<int>((wgt.cells.size() + cols - 1) / cols);
					// column widths were sized in layout; distribute evenly on draw
					int colw = (std::max)(30, wgt.lw / cols);
					for (int r = 0; r < rows; r++) {
						for (int c = 0; c < cols; c++) {
							size_t i = static_cast<size_t>(r) * cols + c;
							if (i >= wgt.cells.size() || wgt.cells[i].empty()) {
								continue;
							}
							uint32_t color = (r == 0) ? ARGB(255, 255, 215, 0) : 0xFFFFFFFF;
							DrawTextStr(wgt.lx + c * colw, wgt.ly + r * 16, wgt.cells[i], color, 14, 0, colw - 6);
						}
					}
					break;
				}
				case NMSW_PROGRESS: {
					FillRect(wgt.lx, wgt.ly, wgt.lw, wgt.lh, ARGB(255, 30, 30, 38));
					int fw = static_cast<int>(wgt.lw * (std::max)(0.f, (std::min)(1.f, wgt.fraction)));
					if (fw > 0) {
						FillRect(wgt.lx, wgt.ly, fw, wgt.lh, wgt.argb ? wgt.argb : ARGB(255, 48, 192, 48));
					}
					if (!wgt.text.empty()) {
						DrawTextStr(wgt.lx + wgt.lw / 2, wgt.ly + 1, wgt.text, 0xFFFFFFFF, 14, 1, 0);
					}
					break;
				}
				case NMSW_INPUT: {
					bool active = (&wgt - win.widgets.data()) == win.active_input;
					FillRect(wgt.lx, wgt.ly, wgt.lw, wgt.lh, active ? ARGB(255, 40, 40, 56) : ARGB(255, 26, 26, 36));
					DrawLine(wgt.lx, wgt.ly + wgt.lh, wgt.lx + wgt.lw, wgt.ly + wgt.lh,
						active ? ARGB(255, 255, 215, 0) : ARGB(120, 140, 140, 150), 1.f);
					std::string shown = active ? win.input_buffer : wgt.text;
					if (active && (GetTickCount() / 350) % 2 == 0) {
						shown += "_";
					}
					DrawTextStr(wgt.lx + 6, wgt.ly + 1, shown, 0xFFFFFFFF, 14, 0, wgt.lw - 10);
					break;
				}
				case NMSW_ICON:
					// real art from <eqdir>\ItemIcons\<id>.png; quad + id if the
					// pack lacks this icon
					FillRect(wgt.lx, wgt.ly, wgt.lw, wgt.lh, ARGB(255, 50, 50, 66));
					DrawIcon(wgt.lx + 2, wgt.ly + 2, wgt.lw - 4, wgt.lh - 4,
						wgt.icon_id, std::to_string(wgt.icon_id));
					break;
				case NMSW_ITEMLINK:
					DrawTextStr(wgt.lx, wgt.ly, wgt.text, ARGB(255, 120, 180, 255), 14, 0, wgt.lw + 60);
					break;
				case NMSW_CANVAS: {
					float scale = 1.f;
					if (wgt.cw > 0 && wgt.ch > 0) {
						float sx = static_cast<float>(wgt.lw) / wgt.cw;
						float sy = static_cast<float>(wgt.lh) / wgt.ch;
						scale = (std::min)(1.f, (std::min)(sx, sy));
					}

					for (const auto& p : wgt.pieces) {
						if (piece_budget-- <= 0) {
							break;
						}
						auto px = [&](int v) { return wgt.lx + static_cast<int>(v * scale); };
						auto py = [&](int v) { return wgt.ly + static_cast<int>(v * scale); };

						switch (p.type) {
							case NMSWP_PANEL: {
								FillRect(px(p.x), py(p.y), static_cast<int>(p.a * scale), static_cast<int>(p.b * scale), p.argb);
								int bp = (std::max)(1, static_cast<int>(p.aux2));
								DrawLine(px(p.x), py(p.y), px(p.x) + static_cast<int>(p.a * scale), py(p.y), ARGB(255, 196, 168, 96), static_cast<float>(bp));
								DrawLine(px(p.x), py(p.y) + static_cast<int>(p.b * scale), px(p.x) + static_cast<int>(p.a * scale), py(p.y) + static_cast<int>(p.b * scale), ARGB(255, 196, 168, 96), static_cast<float>(bp));
								DrawLine(px(p.x), py(p.y), px(p.x), py(p.y) + static_cast<int>(p.b * scale), ARGB(255, 196, 168, 96), static_cast<float>(bp));
								DrawLine(px(p.x) + static_cast<int>(p.a * scale), py(p.y), px(p.x) + static_cast<int>(p.a * scale), py(p.y) + static_cast<int>(p.b * scale), ARGB(255, 196, 168, 96), static_cast<float>(bp));
								break;
							}
							case NMSWP_RECT:
								FillRect(px(p.x), py(p.y), static_cast<int>(p.a * scale), static_cast<int>(p.b * scale), p.argb);
								break;
							case NMSWP_LINE:
								DrawLine(px(p.x), py(p.y), px(p.a), py(p.b), p.argb, (std::max)(1.f, p.aux * scale));
								break;
							case NMSWP_RING:
								DrawRing(px(p.x), py(p.y), (std::max)(1.f, p.a * scale), p.argb, (std::max)(1.f, p.aux * scale));
								break;
							case NMSWP_TEXT:
								DrawTextStr(px(p.x), py(p.y), p.text, p.argb ? p.argb : 0xFFFFFFFF,
									(std::max)(10, static_cast<int>(p.aux * scale)), p.aux2, 0);
								break;
							case NMSWP_BANNER:
								DrawTextStr(wgt.lx + static_cast<int>(wgt.lw / 2), py(p.y), p.text,
									p.argb ? p.argb : ARGB(255, 255, 215, 0),
									(std::max)(14, static_cast<int>(p.aux * scale)), 1, 0);
								break;
							case NMSWP_LABEL:
								FillRect(px(p.x), py(p.y), static_cast<int>(p.a * scale), 14, p.argb ? p.argb : ARGB(200, 40, 44, 60));
								DrawTextStr(px(p.x) + static_cast<int>(p.a * scale) / 2, py(p.y), p.text, 0xFFFFFFFF, 14, 1, static_cast<int>(p.a * scale) - 4);
								break;
							case NMSWP_GRID: {
								for (const auto& cell : p.grid) {
									if (piece_budget-- <= 0) {
										break;
									}
									int col = cell.first % std::max<uint16_t>(1, p.aux);
									int row = cell.first / std::max<uint16_t>(1, p.aux);
									FillRect(px(p.x + col * p.a), py(p.y + row * p.b),
										(std::max)(1, static_cast<int>(p.a * scale)),
										(std::max)(1, static_cast<int>(p.b * scale)), cell.second);
								}
								break;
							}
							case NMSWP_ICON:
								DrawIcon(px(p.x), py(p.y),
									(std::max)(1, static_cast<int>(p.a * scale)),
									(std::max)(1, static_cast<int>(p.b * scale)), p.aux, p.text);
								break;
							case NMSWP_CLICKABLE:
							default:
								break; // invisible
						}
					}
					break;
				}
				default:
					break;
			}
		}
	}

	m_sprite->End();

	state->Apply();
	state->Release();
}

} // namespace NMSWin
