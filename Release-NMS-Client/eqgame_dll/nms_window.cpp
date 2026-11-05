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
		// A plain SIDL client area reports the release as XWM_LMOUSEUP; XWM_LCLICK
		// is what *controls* send. Only listening for LCLICK left the whole window
		// inert -- the title bar still dragged because that is native chrome, but
		// nothing inside it ever answered a click.
		if (Message == XWM_LCLICK || Message == XWM_LMOUSEUP) {
			if (m_close && pWnd == m_close) {
				if (Message == XWM_LCLICK) {
					Manager::Get().SendClosed(*m_win);
				}
				return 1;
			}
			if (m_win) {
				PMOUSEINFO m = EQADDR_MOUSE;
				Manager::Get().ClickWindow(*m_win, static_cast<int>(m->X), static_cast<int>(m->Y));
			}
			return 1;
		}

		// one-shot trace of what else reaches us, so a dead client area can be
		// told apart from a hit-test miss without another round trip
		if (m_win && m_win->msg_log < 8) {
			m_win->msg_log++;
			WriteChatf("[Arcade] wnd msg %u pWnd %p (close %p)", Message, (void*)pWnd, (void*)m_close);
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
				WriteChatf("[Arcade] open id=%u key=%s %ux%u", id, key.c_str(), w, h);
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
						if (!e.frame_logged) {
							e.frame_logged = true;
							WriteChatf("[Arcade] frame for win %u canvas idx %u: %d pieces",
								id, idx, (int)e.widgets[idx].pieces.size());
						}
						break;
					}
				}
				if (!parsed) {
					// per-frame chatter when a ticker window and the widget list
					// disagree: report the first one only
					ArcadeWindow* dw = nullptr;
					for (auto& e : m_wins) {
						if (e.id == id) { dw = &e; break; }
					}
					if (dw && !dw->drop_logged) {
						dw->drop_logged = true;
						WriteChatf("[Arcade] frame DROP win %u idx %u (further drops silent)", id, idx);
					}
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
	int cascade_x = 560 + (open_count % 6) * 48;
	int cascade_y = 120 + (open_count % 6) * 40;

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

	// size the frame to the requested content before it is ever painted
	FitShell(win);

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

// The capability HELLO is idempotent server side (it only sets m_capable), so
// it is re-sent rather than fired once: SetGameState(INGAME) can run before the
// new zone's connection is up, and the 9 bytes are then dropped on the floor --
// that zone process never marks the client capable, the vault falls back to the
// legacy VAULTDATA window and the arcade answers "your client cannot draw
// arcade windows". Only the first one chats.
void Manager::SendHello()
{
	const bool first = !m_hello_sent;
	m_hello_sent = true;

	std::vector<uint8_t> buf;
	buf.push_back(1);
	buf.push_back(NMSW_DLL_VERSION & 0xFF);
	buf.push_back((NMSW_DLL_VERSION >> 8) & 0xFF);
	BytesOut(buf, NMSW_CAP_WINDOWS);
	SendEQMessage(NMSW_OP_EVENT, buf.data(), static_cast<DWORD>(buf.size()));

	if (first) {
		WriteChatf("[Arcade] announcing window support to the server (v%d, build " __DATE__ " " __TIME__ ")", NMSW_DLL_VERSION);
	}
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
	// lives in the zone), so re-announce on every zone-in -- and keep at it in
	// Render, because this state change can precede the zone connection
	SendHello();
	m_next_hello = GetTickCount() + HELLO_INTERVAL_MS;
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
	// one physical click can reach us twice (notification path + the button poll
	// in Render); this guard keeps the first and drops the echo
	const DWORD now = GetTickCount();
	if (now - win.last_click_ms < 150) {
		return true;
	}
	win.last_click_ms = now;

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
			// one line per hit, capped: this is the only diagnostic left, and it
			// prints exactly the kind/action the server judges the event on
			if (win.click_log_count < 6) {
				win.click_log_count++;
				WriteChatf("[Arcade] click %u kind %u action %u at %d,%d",
					win.id, h.kind, h.action, wx, wy);
			}

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
// Give the shell the size the wire asked for. The NMS_ArcadeShell template is
// one fixed 400x320 frame, so without this every script window came out at the
// template's size: blackjack (460x320) had its canvas squashed by the canvas
// fit (min(1, w/cw, h/ch)), and coin_flip (320x250) sat in the top-left corner
// of a much larger frame with its buttons jammed against the bottom edge.
//
// The frame keeps its chrome *inside* the rect it is given, so the shell is
// sized to hold the requested drawing area plus that chrome:
//   width  = 6px border + 6px content inset, both sides            (+24)
//   height = 24px title bar + 6px bottom border + the 7px the
//            layout's first-row offset adds (y starts at 28, +3)   (+37)
// which leaves the interior exactly w x h -- canvas pieces then scale 1:1.
void Manager::FitShell(ArcadeWindow& win)
{
	RECT& rc = WndRect(win.shell);

	int want_w = static_cast<int>(win.w) + 24;
	// The wire's h is the drawing area the script asked for, but the games put
	// their button row *below* the canvas, so the layout usually needs more than
	// h + chrome. Relayout records that in fit_h; without honouring it here this
	// function yanked the frame back to the short size on the next packet and
	// the grow-to-fit below pushed it out again -- a rect that flipped between
	// two heights every tick, with the body drawn to whichever one was current.
	int want_h = (std::max)(static_cast<int>(win.h) + 37, win.fit_h);
	want_w = (std::max)(220, (std::min)(1400, want_w));
	want_h = (std::max)(140, (std::min)(1000, want_h));

	// keep the frame on screen: the cascade opens at x=560 / y=120
	const int scr_w = GetSystemMetrics(SM_CXSCREEN);
	const int scr_h = GetSystemMetrics(SM_CYSCREEN);
	if (rc.left + want_w > scr_w) {
		rc.left = (std::max)(0, scr_w - want_w - 8);
	}
	if (rc.top + want_h > scr_h) {
		rc.top = (std::max)(0, scr_h - want_h - 48);
	}

	const int seen_w = static_cast<int>(rc.right - rc.left);
	const int seen_h = static_cast<int>(rc.bottom - rc.top);
	if (seen_w != want_w || seen_h != want_h) {
		rc.right = rc.left + want_w;
		rc.bottom = rc.top + want_h;

		// One line per window, plus one if the game puts the rect back after we
		// set it: that second case means some other path owns the rect and the
		// frame keeps flipping between the template size and ours.
		// silent: the geometry is settled, and this per-window chatter was most
		// of what showed up in chat
		(void)seen_w;
		(void)seen_h;
	}

	// NMSArcadeClose is authored at X=364 (24x18) for the template's fixed 400px
	// width, so any other frame width would leave it outside the title bar.
	// Anchor it to the right edge on every pass: the SIDL load re-resolves
	// children when the template is (re)parsed. The 24x18 mirrors the XML.
	if (win.close_btn) {
		RECT& c = WndRect(win.close_btn);
		c.top = rc.top + 2;
		c.bottom = c.top + 18;
		c.right = rc.right - 12;
		c.left = c.right - 24;
	}
}

void Manager::Relayout(ArcadeWindow& win)
{
	win.relayout_needed = false;
	win.hits.clear();

	if (!win.shell) {
		return;
	}

	FitShell(win);

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
					wgt_w = interior_w - pad * 2;
					wgt_h = TextHeightWrapped(wgt.text, 14, wgt_w);
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
		else if (line_h > 0 && x + wgt_w + pad > interior_w) {
			// row is full: wrap to the next line rather than squashing the
			// widget into a sliver hanging off the right edge
			x = pad;
			y += line_h + 3;
			line_h = 0;
		}

		// clamp wide widgets to the interior
		if (wgt_w > interior_w - pad * 2) {
			wgt_w = (std::max)(10, interior_w - pad * 2);
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

	// grow the shell when the laid-out content is taller than the interior so
	// widgets never spill past the frame (the layout loop tracks y + line_h)
	{
		RECT& rc2 = WndRect(win.shell);
		const int needed_bottom = y + line_h + pad + 2;
		const int current_bottom = static_cast<int>(rc2.bottom - rc2.top);

		// remember it so FitShell stops resetting the frame to the requested
		// height on the next packet (that fight is what made these windows
		// flicker between two heights, with the buttons hanging off the body)
		win.fit_h = (std::max)(static_cast<int>(win.h) + 37, needed_bottom);

		if (needed_bottom > current_bottom) {
			rc2.bottom = rc2.top + needed_bottom;
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
	for (auto& kv : m_text_tex) {
		if (kv.second.tex) {
			kv.second.tex->Release();
		}
	}
	m_text_tex.clear();
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
			// no ItemIcons art on this client: the server's short item name has to
			// fit inside one slot box, so draw it small and clipped to the cell
			DrawTextStr(x + w / 2, y + (std::max)(0, (h - 12) / 2), fallback_text, 0xFFDDE3F0, 10, 1, w);
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

// ---------------------------------------------------------------------------
// text: GDI rasterised into cached textures
//
// D3DXCreateFontA returns a non-null ID3DXFont on this client, but every
// DrawText call on it -- measuring (DT_CALCRECT) and drawing alike -- returns 0
// and does nothing. That is what collapsed every script window: TextWidth()
// handed back the untouched 4000px probe rect, so each button clamped to the
// full interior width and its label was centred 2000px off the window. GDI text
// works, so measure with GetTextExtentPoint32 and rasterise glyphs into an
// A8R8G8B8 texture that the sprite blits.
// ---------------------------------------------------------------------------
HDC Manager::GdiDC()
{
	if (!m_dc) {
		m_dc = CreateCompatibleDC(nullptr);
	}
	return m_dc;
}

HFONT Manager::GdiFont(int size)
{
	const int px = (size >= 17) ? 18 : 14;
	HFONT& slot = (px >= 17) ? m_hfont18 : m_hfont14;
	if (!slot) {
		slot = CreateFontA(-px, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
			OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY,
			DEFAULT_PITCH | FF_DONTCARE, "Arial");
	}
	return slot;
}

int Manager::TextWidth(const std::string& s, int size)
{
	if (s.empty()) {
		return 0;
	}
	HDC dc = GdiDC();
	HFONT font = GdiFont(size);
	if (!dc || !font) {
		return static_cast<int>(s.size()) * 8;
	}
	HGDIOBJ old = SelectObject(dc, font);
	SIZE sz = {};
	GetTextExtentPoint32A(dc, s.c_str(), static_cast<int>(s.size()), &sz);
	SelectObject(dc, old);
	return sz.cx;
}

int Manager::TextHeightWrapped(const std::string& s, int size, int width)
{
	if (s.empty() || width <= 0) {
		return 16;
	}
	HDC dc = GdiDC();
	HFONT font = GdiFont(size);
	if (!dc || !font) {
		return 16;
	}
	HGDIOBJ old = SelectObject(dc, font);
	RECT rc = {0, 0, width, 0};
	DrawTextA(dc, s.c_str(), -1, &rc, DT_WORDBREAK | DT_CALCRECT | DT_NOPREFIX);
	SelectObject(dc, old);
	return (std::max)(14, static_cast<int>(rc.bottom - rc.top));
}

// Rasterise one string into a white-glyph A8R8G8B8 texture (cached; the sprite
// tints it per draw). Alpha comes from the glyph coverage, RGB is forced white
// so the tint stays clean.
IDirect3DTexture9* Manager::GetTextTexture(const std::string& s, int size, int& out_w, int& out_h)
{
	out_w = out_h = 0;
	if (s.empty() || !m_dev) {
		return nullptr;
	}

	const std::pair<int, std::string> key(size, s);
	auto it = m_text_tex.find(key);
	if (it != m_text_tex.end()) {
		out_w = it->second.w;
		out_h = it->second.h;
		return it->second.tex;
	}
	// cache churn guard: strings are few and stable, but a ticker would grow it
	if (m_text_tex.size() > 512) {
		for (auto& kv : m_text_tex) {
			if (kv.second.tex) {
				kv.second.tex->Release();
			}
		}
		m_text_tex.clear();
	}

	HDC dc = GdiDC();
	HFONT font = GdiFont(size);
	if (!dc || !font) {
		return nullptr;
	}

	HGDIOBJ old_font = SelectObject(dc, font);
	SIZE ext = {};
	if (!GetTextExtentPoint32A(dc, s.c_str(), static_cast<int>(s.size()), &ext) || ext.cx <= 0) {
		SelectObject(dc, old_font);
		return nullptr;
	}
	// headroom on each axis: glyph overhang and descenders sit outside the
	// reported extent often enough to matter on short labels
	const int w = ext.cx + 2;
	const int h = (std::max)(16, static_cast<int>(ext.cy) + 1);

	BITMAPINFO bi = {};
	bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bi.bmiHeader.biWidth = w;
	bi.bmiHeader.biHeight = -h; // top-down
	bi.bmiHeader.biPlanes = 1;
	bi.bmiHeader.biBitCount = 32;
	bi.bmiHeader.biCompression = BI_RGB;

	void* bits = nullptr;
	HBITMAP dib = CreateDIBSection(dc, &bi, DIB_RGB_COLORS, &bits, nullptr, 0);
	if (!dib || !bits) {
		SelectObject(dc, old_font);
		if (dib) {
			DeleteObject(dib);
		}
		return nullptr;
	}
	HGDIOBJ old_bmp = SelectObject(dc, dib);
	SetBkMode(dc, TRANSPARENT);
	SetTextColor(dc, RGB(255, 255, 255));
	TextOutA(dc, 1, 0, s.c_str(), static_cast<int>(s.size()));

	// GDI leaves the alpha channel at 0: derive it from the glyph coverage and
	// force RGB white so the sprite's tint is the only colour source
	uint32_t* px = static_cast<uint32_t*>(bits);
	for (int i = 0; i < w * h; i++) {
		const uint32_t c = px[i];
		const uint32_t a = (std::max)(c & 0xFF, (std::max)((c >> 8) & 0xFF, (c >> 16) & 0xFF));
		px[i] = (a << 24) | 0x00FFFFFF;
	}

	IDirect3DTexture9* tex = nullptr;
	if (FAILED(D3DXCreateTexture(m_dev, w, h, 1, 0, D3DFMT_A8R8G8B8,
			D3DPOOL_MANAGED, &tex)) || !tex) {
		SelectObject(dc, old_bmp);
		SelectObject(dc, old_font);
		DeleteObject(dib);
		return nullptr;
	}

	D3DLOCKED_RECT lk;
	if (SUCCEEDED(tex->LockRect(0, &lk, nullptr, 0))) {
		for (int y = 0; y < h; y++) {
			memcpy(static_cast<uint8_t*>(lk.pBits) + static_cast<size_t>(y) * lk.Pitch,
				static_cast<const uint8_t*>(bits) + static_cast<size_t>(y) * w * 4,
				static_cast<size_t>(w) * 4);
		}
		tex->UnlockRect(0);
	}

	SelectObject(dc, old_bmp);
	SelectObject(dc, old_font);
	DeleteObject(dib);

	TextTex entry;
	entry.tex = tex;
	entry.w = w;
	entry.h = h;
	m_text_tex[key] = entry;

	out_w = w;
	out_h = h;
	return tex;
}

void Manager::DrawTextStr(int x, int y, const std::string& s, uint32_t argb, int size, int align, int clip_w)
{
	if (s.empty() || (argb >> 24) == 0 || !m_sprite) {
		return;
	}

	int w = 0, h = 0;
	IDirect3DTexture9* tex = GetTextTexture(s, size, w, h);
	if (!tex) {
		return;
	}

	int dx = x;
	if (align == 1) {
		dx -= w / 2;
	}
	else if (align == 2) {
		dx -= w;
	}

	if (clip_w > 0 && w > clip_w) {
		// ellipsis by real metrics rather than a texture-wide clip: keep the
		// longest prefix that still fits with "..."
		const int target = (std::max)(8, clip_w);
		std::string cut = s;
		while (!cut.empty() && TextWidth(cut + "...", size) > target) {
			cut.resize(cut.size() - 1);
		}
		if (cut.empty()) {
			return;
		}
		int cw = 0, ch = 0;
		IDirect3DTexture9* t2 = GetTextTexture(cut + "...", size, cw, ch);
		if (!t2) {
			return;
		}
		tex = t2;
		w = cw;
	}

	D3DXVECTOR3 pos(static_cast<float>(m_ofs_x + dx), static_cast<float>(m_ofs_y + y), 0.f);
	m_sprite->Draw(tex, nullptr, nullptr, &pos, Col(argb));
}

// greedy word wrap through the same GDI metrics the layout uses
void Manager::DrawWrapped(int x, int y, int width, const std::string& s, uint32_t argb)
{
	if (s.empty() || width <= 8) {
		return;
	}
	const int line_h = 16;
	std::string line;
	int row = 0;
	size_t i = 0;
	while (i <= s.size()) {
		const size_t space = s.find(' ', i);
		const std::string word = s.substr(i, (space == std::string::npos ? s.size() : space) - i);
		const std::string probe = line.empty() ? word : line + " " + word;
		if (!line.empty() && TextWidth(probe, 14) > width) {
			DrawTextStr(x, y + row * line_h, line, argb, 14, 0, 0);
			++row;
			line = word;
		}
		else {
			line = probe;
		}
		if (space == std::string::npos) {
			break;
		}
		i = space + 1;
		if (row > 64) {
			break;
		}
	}
	if (!line.empty()) {
		DrawTextStr(x, y + row * line_h, line, argb, 14, 0, 0);
	}
}

void Manager::SetScissor(const RECT& rc)
{
	if (!m_dev) {
		return;
	}
	D3DVIEWPORT9 vp = {};
	if (FAILED(m_dev->GetViewport(&vp))) {
		return;
	}
	// an out-of-bounds scissor rect makes SetScissorRect fail (and the previous
	// rect stay in force), so clamp to the viewport first
	RECT r = rc;
	if (r.left < static_cast<LONG>(vp.X)) {
		r.left = static_cast<LONG>(vp.X);
	}
	if (r.top < static_cast<LONG>(vp.Y)) {
		r.top = static_cast<LONG>(vp.Y);
	}
	if (r.right > static_cast<LONG>(vp.X + vp.Width)) {
		r.right = static_cast<LONG>(vp.X + vp.Width);
	}
	if (r.bottom > static_cast<LONG>(vp.Y + vp.Height)) {
		r.bottom = static_cast<LONG>(vp.Y + vp.Height);
	}
	if (r.right <= r.left || r.bottom <= r.top) {
		return;
	}
	m_dev->SetRenderState(D3DRS_SCISSORTESTENABLE, TRUE);
	m_dev->SetScissorRect(&r);
}

void Manager::ClearScissor()
{
	if (m_dev) {
		m_dev->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
	}
}

// ---------------------------------------------------------------------------
// render (EndScene hook)
// ---------------------------------------------------------------------------
void Manager::Render()
{
	// slow capability heartbeat: see SendHello. Cheap enough (9 bytes / 5s) to
	// leave running for the whole session, and it heals a dropped zone-in HELLO
	if (GetGameState() == GAMESTATE_INGAME &&
		static_cast<int32_t>(GetTickCount() - m_next_hello) >= 0) {
		m_next_hello = GetTickCount() + HELLO_INTERVAL_MS;
		SendHello();
	}

	if (m_wins.empty()) {
		return;
	}

	// A SIDL client area that owns no child controls never delivers click
	// notifications to the window itself, so WndNotification is never called for
	// it -- which is why the whole panel was inert while its title bar still
	// dragged. Poll the physical button here instead (Render runs every frame)
	// and use the MouseOver byte EQ maintains on the topmost window under the
	// cursor: if ours is the one being hovered, the click belongs to us.
	if (GetGameState() == GAMESTATE_INGAME) {
		const bool down = (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
		const bool pressed = down && !m_lbutton_down;
		m_lbutton_down = down;
		if (pressed) {
			PMOUSEINFO m = EQADDR_MOUSE;
			const int mx = static_cast<int>(m->X);
			const int my = static_cast<int>(m->Y);

			// Topmost of *our* windows under the cursor wins. CXWnd::MouseOver
			// looked like the natural test, but its offset in this client build
			// reads 0 for a window that is plainly under the cursor, so the poll
			// never claimed anything. Geometry first; the frame rect is the one
			// field we know is right because the interior tracks it while dragged.
			ArcadeWindow* target = nullptr;
			for (auto& win : m_wins) {
				if (!win.shell) {
					continue;
				}
				RECT& r = WndRect(win.shell);
				if (mx >= r.left && mx < r.right && my >= r.top && my < r.bottom) {
					target = &win;
				}
			}
			if (target) {
				ClickWindow(*target, mx, my);
			}
		}
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
		m_dev_ok = m_sprite && m_line != nullptr;
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
		if (!win.draw_logged) {
			win.draw_logged = true;
			int pieces = 0;
			for (auto& w : win.widgets) { pieces += (int)w.pieces.size(); }
			WriteChatf("[Arcade] draw win %u: %d widgets, %d canvas pieces",
				win.id, (int)win.widgets.size(), pieces);
		}

		RECT& rc = WndRect(win.shell);
		m_ofs_x = rc.left;
		m_ofs_y = rc.top;
		// content must never paint outside its own frame: without this a window
		// whose layout overflows spills over neighbouring UI (and over the game)
		SetScissor(rc);
		int interior_w = (std::max)(50, static_cast<int>(rc.right - rc.left) - 12);
		int interior_h = (std::max)(40, static_cast<int>(rc.bottom - rc.top) - 30);

		uint32_t bg = win.style_bg ? win.style_bg : ARGB(255, 18, 19, 30);
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
						DrawWrapped(wgt.lx, wgt.ly, wgt.lw, wgt.text,
							wgt.argb ? wgt.argb : 0xFFFFFFFF);
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
					// light faces (the gold "current page" tab) need dark ink
					const int luma = static_cast<int>(((face >> 16) & 0xFF) * 30 +
						((face >> 8) & 0xFF) * 59 + (face & 0xFF) * 11) / 100;
					uint32_t tcol = wgt.disabled ? ARGB(255, 150, 150, 150)
						: (luma > 140 ? ARGB(255, 20, 20, 26) : 0xFFFFFFFF);
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
								// Slot boxes, live-NMS style: a 2px gutter between
								// cells, then a light top/left and dark bottom/right
								// bevel. Filling the whole cell and outlining it in one
								// mid tone was what made the grid read as a single dark
								// slab with a faint lattice on it.
								const int cw = (std::max)(1, static_cast<int>(p.a * scale));
								const int chh = (std::max)(1, static_cast<int>(p.b * scale));
								const int bw = (std::max)(1, cw - 2);
								const int bh = (std::max)(1, chh - 2);
								int cells = 0;
								for (const auto& cell : p.grid) {
									if (piece_budget-- <= 0) {
										break;
									}
									const int col = cell.first % std::max<uint16_t>(1, p.aux);
									const int row = cell.first / std::max<uint16_t>(1, p.aux);
									const int bx = px(p.x + col * p.a) + 1;
									const int by = py(p.y + row * p.b) + 1;

									FillRect(bx, by, bw, bh, cell.second);
									FillRect(bx, by, bw, 1, ARGB(255, 152, 166, 206));              // top
									FillRect(bx, by, 1, bh, ARGB(255, 118, 132, 172));              // left
									FillRect(bx, by + bh - 1, bw, 1, ARGB(255, 28, 32, 44));        // bottom
									FillRect(bx + bw - 1, by, 1, bh, ARGB(255, 40, 46, 62));        // right
									if (++cells > 4096) {
										break;
									}
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
		ClearScissor();
	}

	m_sprite->End();

	state->Apply();
	state->Release();
}

} // namespace NMSWin
