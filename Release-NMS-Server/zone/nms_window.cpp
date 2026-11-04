#include "nms_window.h"

#include "client.h"
#include "entity.h"
#include "npc.h"
#include "nms_vault.h"
#include "quest_parser_collection.h"
#include "questmgr.h"
#include "../common/rulesys.h"
#include "zonedb.h"
#include "zone.h"

#include "../common/eq_constants.h"
#include "../common/eq_packet.h"
#include "../common/emu_opcodes.h"
#include "../common/strings.h"

#include <algorithm>
#include <chrono>
#include <cstring>
#include <memory>
#include <unordered_map>
#include <fmt/format.h>

using namespace EQ::NMS;

// ---------------------------------------------------------------------------
// little-endian buffer writer (same conventions as the housing Writer)
// ---------------------------------------------------------------------------
namespace {

class Buf {
public:
	void U8(uint8_t v) { m_buf.push_back(v); }
	void U16(uint16_t v)
	{
		m_buf.push_back(static_cast<uint8_t>(v & 0xFF));
		m_buf.push_back(static_cast<uint8_t>((v >> 8) & 0xFF));
	}
	void U32(uint32_t v)
	{
		for (int i = 0; i < 4; i++) {
			m_buf.push_back(static_cast<uint8_t>((v >> (8 * i)) & 0xFF));
		}
	}
	void I16(int16_t v) { U16(static_cast<uint16_t>(v)); }
	void F32(float v)
	{
		uint32_t bits;
		memcpy(&bits, &v, sizeof(bits));
		U32(bits);
	}
	void Str(const std::string& s)
	{
		size_t n = std::min<size_t>(s.size(), 0xFFFF);
		U16(static_cast<uint16_t>(n));
		m_buf.insert(m_buf.end(), s.data(), s.data() + n);
	}
	void Raw(const std::string& s) { m_buf.insert(m_buf.end(), s.begin(), s.end()); }

	std::vector<uint8_t>& Get() { return m_buf; }
	bool Empty() const { return m_buf.empty(); }

private:
	std::vector<uint8_t> m_buf;
};

const uint8_t MSG_OPEN   = 1;
const uint8_t MSG_CLOSE  = 2;
const uint8_t MSG_CLEAR  = 3;
const uint8_t MSG_WIDGET = 4;
const uint8_t MSG_STYLE  = 6;
const uint8_t MSG_FRAME  = 7;
const uint8_t MSG_LOCALACTION = 8;

const size_t NMS_MAX_WIDGETS    = 256;
const size_t NMS_MAX_TEXT_BYTES = 512;
const size_t NMS_MAX_TABLE_BYTES = 6000;
const size_t NMS_MAX_FRAME_BYTES = 16384;

uint32 NowSec()
{
	return static_cast<uint32_t>(
		std::chrono::duration_cast<std::chrono::seconds>(
			std::chrono::steady_clock::now().time_since_epoch())
			.count());
}

std::string ClampText(const std::string& s, size_t max_bytes)
{
	if (s.size() <= max_bytes) {
		return s;
	}
	return s.substr(0, max_bytes);
}

uint32 ColorOrZero(const std::string& color)
{
	return ParseWindowColor(color, 0xFFFFFFFF);
}

struct ColorName {
	const char* name;
	uint32 argb;
};

const ColorName kColorNames[] = {
	{"white", 0xFFFFFFFF}, {"black", 0xFF000000}, {"red", 0xFFC02020},
	{"green", 0xFF30C030}, {"blue", 0xFF3050C0}, {"gold", 0xFFFFD700},
	{"yellow", 0xFFFFFF00}, {"orange", 0xFFFFA500}, {"cyan", 0xFF00CED1},
	{"purple", 0xFF9F30C0}, {"gray", 0xFF909090}, {"grey", 0xFF909090},
	{"pink", 0xFFFF69B4},
};

void SendBuf(Client* c, Buf& b)
{
	if (!c || b.Empty()) {
		return;
	}

	auto outapp = new EQApplicationPacket(OP_NMSWindowData, static_cast<uint32_t>(b.Get().size()));
	memcpy(outapp->pBuffer, b.Get().data(), b.Get().size());
	c->QueuePacket(outapp);
	safe_delete(outapp);
}

} // namespace

// "gold" / "#RRGGBB" / "0xAARRGGBB" / decimal int / "none" -> ARGB.
uint32 EQ::NMS::ParseWindowColor(const std::string& color, uint32 def)
{
	if (color.empty()) {
		return def;
	}

	std::string c;
	c.reserve(color.size());
	for (char ch : color) {
		c.push_back(static_cast<char>(tolower(static_cast<unsigned char>(ch))));
	}

	if (c == "none") {
		return 0;
	}

	for (const auto& entry : kColorNames) {
		if (c == entry.name) {
			return entry.argb;
		}
	}

	std::string hex = c;
	if (!hex.empty() && hex[0] == '#') {
		hex = hex.substr(1);
	}
	else if (hex.rfind("0x", 0) == 0) {
		hex = hex.substr(2);
	}

	if (hex.size() == 6 || hex.size() == 8) {
		uint64_t value = 0;
		bool ok = true;
		for (char ch : hex) {
			value <<= 4;
			if (ch >= '0' && ch <= '9') { value |= (ch - '0'); }
			else if (ch >= 'a' && ch <= 'f') { value |= (ch - 'a' + 10); }
			else if (ch >= 'A' && ch <= 'F') { value |= (ch - 'A' + 10); }
			else { ok = false; break; }
		}
		if (ok) {
			if (hex.size() == 6) {
				value |= 0xFF000000ULL;
			}
			return static_cast<uint32_t>(value);
		}
	}

	// raw decimal (Lua numbers arriving as text)
	if (!c.empty() && c.find_first_not_of("0123456789") == std::string::npos) {
		return static_cast<uint32_t>(strtoull(c.c_str(), nullptr, 10));
	}

	return def;
}

// ---------------------------------------------------------------------------
// WindowManager
// ---------------------------------------------------------------------------

WindowManager::WindowManager(Client* c) : m_client(c)
{
}

WindowManager::~WindowManager()
{
	if (m_tickers && zone) {
		zone->NmsTickerWindowsAdd(-static_cast<int>(m_tickers));
		m_tickers = 0;
	}
}

Window* WindowManager::FindWindow(int window_id)
{
	for (auto& win : m_windows) {
		if (win.id == static_cast<uint32_t>(window_id)) {
			return &win;
		}
	}
	return nullptr;
}

bool WindowManager::ConsumeSendBudget()
{
	uint32 sec = NowSec();
	if (sec != m_budget_sec) {
		m_budget_sec = sec;
		m_packets_this_sec = 0;
		m_events_this_sec = 0;
	}

	if (m_packets_this_sec >= static_cast<uint32_t>(RuleI(Custom, NMSWindowMaxPacketsPerSec))) {
		return false;
	}

	m_packets_this_sec++;
	return true;
}

bool WindowManager::ConsumeEventBudget()
{
	uint32 sec = NowSec();
	if (sec != m_budget_sec) {
		m_budget_sec = sec;
		m_packets_this_sec = 0;
		m_events_this_sec = 0;
	}

	if (m_events_this_sec >= static_cast<uint32_t>(RuleI(Custom, NMSWindowMaxEventsPerSec))) {
		return false;
	}

	m_events_this_sec++;
	return true;
}

bool WindowManager::IsSupported() const
{
	return RuleB(Custom, NMSWindowEnabled) && m_capable;
}

int WindowManager::Open(const std::string& key, const std::string& title, int w, int h, int flags)
{
	if (!m_client || !RuleB(Custom, NMSWindowEnabled)) {
		return 0;
	}

	// normalize the key: letters, digits, '_', '.', '-' only; cut to 32
	std::string clean;
	clean.reserve(key.size());
	for (char ch : key) {
		if (isalnum(static_cast<unsigned char>(ch)) || ch == '_' || ch == '.' || ch == '-') {
			clean.push_back(ch);
		}
	}
	if (clean.empty()) {
		return 0;
	}
	if (clean.size() > 32) {
		clean.resize(32);
	}

	Window* existing = nullptr;
	for (auto& win : m_windows) {
		if (win.key == clean) {
			existing = &win;
			break;
		}
	}

	uint32 wanted_flags = static_cast<uint32_t>(flags) &
		(WFNoResize | WFCaptureKeys | WFNoClose | WFPopout | WFAutoSize | WFTicker | WFNoTitleBar);
	bool want_ticker = (wanted_flags & WFTicker) != 0;

	if (existing) {
		// same key while open: same id, refresh title/size/flags, content resent on Send
		if (want_ticker && !existing->is_ticker && zone) {
			if (zone->NmsTickerWindows() >= static_cast<uint32_t>(RuleI(Custom, NMSWindowMaxTickers))) {
				return 0;
			}
			zone->NmsTickerWindowsAdd(1);
			m_tickers++;
			existing->is_ticker = true;
		}
		existing->title = ClampText(title, 64);
		existing->w = static_cast<uint16_t>(std::max(64, std::min(1600, w)));
		existing->h = static_cast<uint16_t>(std::max(48, std::min(1200, h)));
		existing->flags = wanted_flags;
		existing->sent_full = false;
		for (auto& wgt : existing->widgets) {
			wgt.needs_send = true;
		}
		return static_cast<int>(existing->id);
	}

	if (m_windows.size() >= static_cast<size_t>(RuleI(Custom, NMSWindowMaxWindows))) {
		m_client->Message(Chat::Yellow, "You cannot open any more windows.");
		return 0;
	}

	if (want_ticker && (!zone || zone->NmsTickerWindows() >= static_cast<uint32_t>(RuleI(Custom, NMSWindowMaxTickers)))) {
		return 0;
	}

	Window win;
	win.id = m_next_id++;
	win.key = clean;
	win.title = ClampText(title, 64);
	win.w = static_cast<uint16_t>(std::max(64, std::min(1600, w)));
	win.h = static_cast<uint16_t>(std::max(48, std::min(1200, h)));
	win.flags = wanted_flags;
	win.is_ticker = want_ticker;

	// capture the quest owner (the NPC whose script opened the window)
	if (quest_manager.QuestsRunning()) {
		Mob* owner = quest_manager.GetOwner();
		if (owner && owner->IsNPC()) {
			win.owner_entity_id = owner->GetID();
			win.owner_npc_type_id = owner->CastToNPC()->GetNPCTypeID();
		}
	}

	m_windows.push_back(std::move(win));

	if (want_ticker) {
		if (zone) {
			zone->NmsTickerWindowsAdd(1);
		}
		m_tickers++;
	}

	return static_cast<int>(m_windows.back().id);
}

bool WindowManager::Close(int window_id)
{
	Window* win = FindWindow(window_id);
	if (!win) {
		return false;
	}

	uint32_t wid = win->id;

	if (m_client && m_capable) {
		Buf b;
		b.U8(MSG_CLOSE);
		b.U32(wid);
		if (ConsumeSendBudget()) {
			SendBuf(m_client, b);
		}
	}

	for (auto it = m_windows.begin(); it != m_windows.end(); ++it) {
		if (it->id == wid) {
			RemoveTicker(*it);
			m_windows.erase(it);
			break;
		}
	}
	return true;
}

bool WindowManager::IsOpen(int window_id) const
{
	for (const auto& win : m_windows) {
		if (win.id == static_cast<uint32_t>(window_id)) {
			return true;
		}
	}
	return false;
}

bool WindowManager::Send(int window_id)
{
	if (!m_client) {
		return false;
	}

	Window* win = FindWindow(window_id);
	if (!win) {
		return false;
	}

	if (!m_capable) {
		// plain-text fallback: render to yellow chat lines
		FallbackRender(*win);
		return true;
	}

	if (!ConsumeSendBudget()) {
		return false;
	}

	Buf b;

	if (!win->sent_full) {
		b.U8(MSG_OPEN);
		b.U32(win->id);
		b.Str(win->key);
		b.Str(win->title);
		b.U16(win->w);
		b.U16(win->h);
		b.U8(static_cast<uint8_t>(win->flags & 0xFF));
	}

	if (win->style_dirty || !win->sent_full) {
		b.U8(MSG_STYLE);
		b.U32(win->id);
		b.U32(win->style_bg);
		b.U32(win->style_border);
		b.U8(win->style_rounding);
		b.U8(win->style_border_px);
		win->style_dirty = false;
	}

	for (auto& wgt : win->widgets) {
		if (!win->sent_full || wgt.needs_send) {
			SerializeWidget(b.Get(), MSG_WIDGET, *win, wgt);
			wgt.needs_send = false;
			wgt.sent = true;
		}
		if (wgt.frame_dirty) {
			b.U8(MSG_FRAME);
			b.U32(win->id);
			b.U16(static_cast<uint16_t>(&wgt - win->widgets.data()));
			b.U16(wgt.frame_count);
			b.Raw(wgt.frame_buf);
			wgt.frame_dirty = false;
		}
	}

	win->sent_full = true;

	if (b.Empty()) {
		return true;
	}

	SendBuf(m_client, b);
	return true;
}

void WindowManager::SerializeWidget(std::vector<uint8_t>& sink, uint8_t msg, const Window& win, const Widget& wgt) const
{
	Buf b;
	b.U8(msg);
	b.U32(win.id);
	b.U16(static_cast<uint16_t>(&wgt - win.widgets.data()));
	b.U8(wgt.kind);
	b.U8(wgt.same_line ? 1 : 0);

	switch (wgt.kind) {
		case WidgetHeader:
		case WidgetText:
			b.U32(wgt.argb);
			b.U8(wgt.wrap ? 1 : 0);
			b.Str(wgt.text);
			break;
		case WidgetSep:
		case WidgetSameLine:
			break;
		case WidgetButton:
			b.Str(wgt.text);
			b.U32(wgt.argb);
			b.U16(wgt.action);
			b.U8(wgt.disabled ? 1 : 0);
			break;
		case WidgetTable:
			b.U8(wgt.cols);
			b.U16(static_cast<uint16_t>(wgt.cells.size()));
			for (const auto& cell : wgt.cells) {
				b.Str(cell);
			}
			break;
		case WidgetProgress:
			b.F32(wgt.fraction);
			b.Str(wgt.text);
			break;
		case WidgetInput:
			b.U16(wgt.action);
			b.U8(wgt.icon_size); // maxlen lives here for inputs
			b.Str(wgt.text);
			break;
		case WidgetIcon:
			b.U32(wgt.icon_id);
			b.U8(wgt.icon_size);
			break;
		case WidgetItemLink:
			b.U32(wgt.item_id);
			b.Str(wgt.text);
			break;
		case WidgetCanvas:
			b.U16(wgt.cw);
			b.U16(wgt.ch);
			break;
	}

	sink.insert(sink.end(), b.Get().begin(), b.Get().end());
}

// ---------------------------------------------------------------------------
// widget API
// ---------------------------------------------------------------------------

namespace {

Widget* WidgetAt(Window* win, int widget)
{
	if (!win || widget < 0 || widget >= static_cast<int>(win->widgets.size())) {
		return nullptr;
	}
	return &win->widgets[static_cast<size_t>(widget)];
}

// a trailing SameLine marker donates its flag to the next widget without
// popping, so indexes stay stable across the whole build
void TakeSameLine(Window* win, Widget& wgt)
{
	if (win && !win->widgets.empty() && win->widgets.back().kind == WidgetSameLine) {
		wgt.same_line = true;
	}
}

} // namespace

int WindowManager::AddHeader(int window_id, const std::string& text, const std::string& color)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetHeader;
	wgt.argb = ColorOrZero(color.empty() ? "gold" : color);
	wgt.text = ClampText(text, NMS_MAX_TEXT_BYTES);
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

int WindowManager::AddText(int window_id, const std::string& text, const std::string& color, bool wrap)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetText;
	wgt.wrap = wrap;
	wgt.argb = ColorOrZero(color);
	wgt.text = ClampText(text, NMS_MAX_TEXT_BYTES);
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::Clear(int window_id)
{
	Window* win = FindWindow(window_id);
	if (!win) {
		return false;
	}

	if (m_client && m_capable) {
		Buf b;
		b.U8(MSG_CLEAR);
		b.U32(win->id);
		if (ConsumeSendBudget()) {
			SendBuf(m_client, b);
		}
	}

	win->widgets.clear();
	win->sent_full = false;
	win->fallback_rendered = false;
	return true;
}

int WindowManager::AddSeparator(int window_id)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetSep;
	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

int WindowManager::AddSameLine(int window_id)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	// marker widget: it consumes an index and the next Add joins this row
	Widget wgt;
	wgt.kind = WidgetSameLine;
	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

int WindowManager::AddButton(int window_id, const std::string& label, int action, const std::string& color)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}
	if (action < 0 || action > 0xFFFF) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetButton;
	wgt.text = ClampText(label, NMS_MAX_TEXT_BYTES);
	wgt.action = static_cast<uint16_t>(action);
	wgt.argb = color.empty() ? 0 : ColorOrZero(color);
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::SetButton(int window_id, int widget, const std::string& label, const std::string& color, bool disabled)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt || wgt->kind != WidgetButton) {
		return false;
	}

	wgt->text = ClampText(label, NMS_MAX_TEXT_BYTES);
	wgt->argb = color.empty() ? wgt->argb : ColorOrZero(color);
	wgt->disabled = disabled;
	wgt->needs_send = true;
	return true;
}

int WindowManager::AddTable(int window_id, const std::vector<std::string>& headers, const std::vector<std::vector<std::string>>& rows)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	size_t cols = headers.size();
	if (cols < 1 || cols > 32) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetTable;
	wgt.cols = static_cast<uint8_t>(cols);
	wgt.cells = headers;
	for (const auto& row : rows) {
		for (size_t i = 0; i < cols; i++) {
			wgt.cells.push_back(i < row.size() ? ClampText(row[i], 512) : std::string());
		}
	}

	if (wgt.cells.size() > 2000) {
		return -1;
	}

	size_t bytes = 0;
	for (const auto& cell : wgt.cells) {
		bytes += cell.size();
	}
	if (bytes > NMS_MAX_TABLE_BYTES) {
		return -1;
	}

	TakeSameLine(win, wgt);
	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

int WindowManager::AddTablePacked(int window_id, int cols, const std::string& packed)
{
	if (cols < 1 || cols > 32) {
		return -1;
	}

	std::vector<std::string> cells;
	std::string current;
	for (char ch : packed) {
		if (ch == '\x1F') {
			cells.push_back(current);
			current.clear();
		}
		else {
			current.push_back(ch);
		}
	}
	cells.push_back(current);

	if (cells.size() < static_cast<size_t>(cols) || cells.empty()) {
		return -1;
	}

	std::vector<std::string> headers(cells.begin(), cells.begin() + cols);
	std::vector<std::vector<std::string>> rows;
	for (size_t i = cols; i < cells.size(); i += static_cast<size_t>(cols)) {
		rows.emplace_back(cells.begin() + static_cast<long>(i),
			cells.begin() + static_cast<long>(std::min(cells.size(), i + static_cast<size_t>(cols))));
	}

	return AddTable(window_id, headers, rows);
}

int WindowManager::AddProgress(int window_id, double fraction, const std::string& color, const std::string& overlay)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetProgress;
	wgt.fraction = static_cast<float>(std::max(0.0, std::min(1.0, fraction)));
	wgt.argb = ColorOrZero(color.empty() ? "green" : color);
	wgt.text = ClampText(overlay, NMS_MAX_TEXT_BYTES);
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::SetProgress(int window_id, int widget, double fraction, const std::string& overlay)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt || wgt->kind != WidgetProgress) {
		return false;
	}

	wgt->fraction = static_cast<float>(std::max(0.0, std::min(1.0, fraction)));
	if (!overlay.empty()) {
		wgt->text = ClampText(overlay, NMS_MAX_TEXT_BYTES);
	}
	wgt->needs_send = true;
	return true;
}

int WindowManager::AddInput(int window_id, int action, int maxlen, const std::string& text)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}
	if (action < 0 || action > 0xFFFF || maxlen < 1 || maxlen > 128) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetInput;
	wgt.action = static_cast<uint16_t>(action);
	wgt.icon_size = static_cast<uint8_t>(maxlen); // reused as maxlen
	wgt.text = ClampText(text, 128);
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::SetText(int window_id, int widget, const std::string& text)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt) {
		return false;
	}

	if (wgt->kind == WidgetText || wgt->kind == WidgetHeader) {
		wgt->text = ClampText(text, NMS_MAX_TEXT_BYTES);
		wgt->needs_send = true;
		return true;
	}
	if (wgt->kind == WidgetInput) {
		wgt->text = ClampText(text, 128);
		wgt->needs_send = true;
		return true;
	}
	return false;
}

int WindowManager::AddIcon(int window_id, int icon_id, int size)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}
	if (icon_id <= 0) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetIcon;
	wgt.icon_id = static_cast<uint32_t>(icon_id);
	wgt.icon_size = static_cast<uint8_t>(std::max(16, std::min(96, size)));
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

int WindowManager::AddItemLink(int window_id, int item_id)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}
	if (item_id <= 0) {
		return -1;
	}

	// resolve the item name so the fallback can print it and the client can
	// render the link label without a lookup
	auto results = database.QueryDatabase(
		fmt::format("SELECT `name` FROM `items` WHERE `id` = {} LIMIT 1", item_id));
	if (!results.Success() || results.RowCount() == 0) {
		return -1;
	}

	std::string item_name;
	for (auto row : results) {
		item_name = std::string(row[0] ? row[0] : "");
		break;
	}

	Widget wgt;
	wgt.kind = WidgetItemLink;
	wgt.item_id = static_cast<uint32_t>(item_id);
	wgt.text = item_name;
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::SetStyle(int window_id, const std::string& bg, const std::string& border, int rounding, int border_px)
{
	Window* win = FindWindow(window_id);
	if (!win) {
		return false;
	}

	win->style_bg = ColorOrZero(bg);
	win->style_border = ColorOrZero(border);
	win->style_rounding = static_cast<uint8_t>(std::max(0, std::min(32, rounding)));
	win->style_border_px = static_cast<uint8_t>(std::max(0, std::min(8, border_px)));
	win->style_dirty = true;
	return true;
}

int WindowManager::AddCanvas(int window_id, int cw, int ch)
{
	Window* win = FindWindow(window_id);
	if (!win || win->widgets.size() >= NMS_MAX_WIDGETS) {
		return -1;
	}

	Widget wgt;
	wgt.kind = WidgetCanvas;
	wgt.cw = static_cast<uint16_t>(std::max(0, std::min(1600, cw)));
	wgt.ch = static_cast<uint16_t>(std::max(0, std::min(1200, ch)));
	TakeSameLine(win, wgt);

	win->widgets.push_back(std::move(wgt));
	return static_cast<int>(win->widgets.size() - 1);
}

bool WindowManager::BeginCanvasFrame(int window_id, int widget)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt || wgt->kind != WidgetCanvas) {
		return false;
	}

	wgt->frame_buf.clear();
	wgt->frame_count = 0;
	wgt->frame_dirty = true;
	return true;
}

bool WindowManager::AddCanvasPieceCSV(int window_id, int widget, const std::string& spec)
{
	// "type,x,y,a,b,argb,aux,aux2,aux3,text" (text optional, may contain commas)
	int v[9] = {0};
	size_t pos = 0;
	for (int i = 0; i < 9; i++) {
		size_t comma = spec.find(',', pos);
		if (comma == std::string::npos) {
			return false;
		}
		v[i] = atoi(spec.substr(pos, comma - pos).c_str());
		pos = comma + 1;
	}

	std::string text = (pos < spec.size()) ? spec.substr(pos) : std::string();
	return AddCanvasPiece(window_id, widget, v[0], v[1], v[2], v[3], v[4],
		static_cast<uint32_t>(v[5]), v[6], v[7], v[8], text);
}

bool WindowManager::AddCanvasGridCSV(int window_id, int widget, const std::string& spec, const std::string& packed_colors)
{
	// "x,y,cols,rows,cellw,cellh,action"
	int v[7] = {0};
	size_t pos = 0;
	for (int i = 0; i < 7; i++) {
		size_t comma = spec.find(',', pos);
		if (comma == std::string::npos) {
			return false;
		}
		v[i] = atoi(spec.substr(pos, comma - pos).c_str());
		pos = comma + 1;
	}

	return AddCanvasGrid(window_id, widget, v[0], v[1], v[2], v[3], v[4], v[5], v[6], packed_colors);
}

bool WindowManager::AddCanvasPiece(int window_id, int widget, int type, int x, int y, int a, int b,
	uint32_t argb, int aux, int aux2, int aux3, const std::string& text)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt || wgt->kind != WidgetCanvas) {
		return false;
	}

	if (wgt->frame_count >= static_cast<uint16_t>(RuleI(Custom, NMSWindowCanvasPieces)) ||
		wgt->frame_buf.size() + 19 + text.size() > NMS_MAX_FRAME_BYTES) {
		return false;
	}

	Buf piece;
	piece.U8(static_cast<uint8_t>(type));
	piece.I16(static_cast<int16_t>(x));
	piece.I16(static_cast<int16_t>(y));
	piece.I16(static_cast<int16_t>(a));
	piece.I16(static_cast<int16_t>(b));
	piece.U32(argb);
	piece.U16(static_cast<uint16_t>(aux));
	piece.U16(static_cast<uint16_t>(aux2));
	piece.U16(static_cast<uint16_t>(aux3));
	switch (type) {
		case PieceText:
		case PieceBanner:
		case PieceLabel:
		// the client reads a fallback label for icon pieces (it shows the text
		// when <eqdir>\ItemIcons\<id>.png is missing); leaving it off the wire
		// desyncs the frame payload and the widgets after it are dropped
		case PieceIcon:
			piece.Str(text);
			break;
		default:
			break;
	}

	wgt->frame_buf.insert(wgt->frame_buf.end(), piece.Get().begin(), piece.Get().end());
	wgt->frame_count++;
	wgt->frame_dirty = true;
	return true;
}

bool WindowManager::AddCanvasGrid(int window_id, int widget, int x, int y, int cols, int rows,
	int cellw, int cellh, int action, const std::string& packed_colors)
{
	Window* win = FindWindow(window_id);
	Widget* wgt = WidgetAt(win, widget);
	if (!wgt || wgt->kind != WidgetCanvas) {
		return false;
	}

	if (cols < 1 || rows < 1 || cols * rows > 4096) {
		return false;
	}

	if (wgt->frame_count >= static_cast<uint16_t>(RuleI(Custom, NMSWindowCanvasPieces))) {
		return false;
	}

	// packed_colors: "idx,argb" joined by 0x1F
	std::vector<std::pair<uint16_t, uint32_t>> filled;
	std::string current;
	auto flush_entry = [&filled, &current]() {
		if (current.empty()) {
			return;
		}
		size_t comma = current.find(',');
		if (comma != std::string::npos) {
			filled.emplace_back(
				static_cast<uint16_t>(strtoul(current.substr(0, comma).c_str(), nullptr, 10)),
				static_cast<uint32_t>(strtoull(current.substr(comma + 1).c_str(), nullptr, 10)));
		}
		current.clear();
	};
	for (char ch : packed_colors) {
		if (ch == '\x1F') {
			flush_entry();
		}
		else {
			current.push_back(ch);
		}
	}
	flush_entry();

	Buf b;
	b.U8(PieceGrid);
	b.I16(static_cast<int16_t>(x));
	b.I16(static_cast<int16_t>(y));
	b.I16(static_cast<int16_t>(cellw));
	b.I16(static_cast<int16_t>(cellh));
	b.U32(0);
	b.U16(static_cast<uint16_t>(cols));
	b.U16(static_cast<uint16_t>(rows));
	b.U16(static_cast<uint16_t>(action));
	b.U16(static_cast<uint16_t>(filled.size()));
	for (const auto& entry : filled) {
		b.U16(entry.first);
		b.U32(entry.second);
	}

	wgt->frame_buf.insert(wgt->frame_buf.end(), b.Get().begin(), b.Get().end());
	wgt->frame_count++;
	wgt->frame_dirty = true;
	return true;
}

// ---------------------------------------------------------------------------
// plain-text fallback (clients without the patched dll)
// ---------------------------------------------------------------------------

void WindowManager::FallbackRender(Window& win)
{
	if (!m_client) {
		return;
	}

	if (!win.fallback_rendered) {
		m_client->Message(Chat::Yellow, "[%s]", win.title.c_str());
		win.fallback_rendered = true;
	}

	for (auto& wgt : win.widgets) {
		if (!wgt.needs_send && wgt.sent) {
			continue;
		}

		switch (wgt.kind) {
			case WidgetHeader:
			case WidgetText:
				m_client->Message(Chat::Yellow, "%s", wgt.text.c_str());
				break;
			case WidgetProgress: {
				int percent = static_cast<int>(wgt.fraction * 100.0f + 0.5f);
				if (wgt.text.empty()) {
					m_client->Message(Chat::Yellow, "%d%%", percent);
				}
				else {
					m_client->Message(Chat::Yellow, "%s: %d%%", wgt.text.c_str(), percent);
				}
				break;
			}
			case WidgetItemLink:
				m_client->Message(Chat::Yellow, "%s", wgt.text.c_str());
				break;
			case WidgetTable: {
				std::string row;
				for (size_t i = 0; i < wgt.cells.size(); i++) {
					if (!row.empty()) {
						row += " | ";
					}
					row += wgt.cells[i];
					if ((i + 1) % wgt.cols == 0 && i + 1 < wgt.cells.size()) {
						m_client->Message(Chat::Yellow, "%s", row.c_str());
						row.clear();
					}
				}
				if (!row.empty()) {
					m_client->Message(Chat::Yellow, "%s", row.c_str());
				}
				break;
			}
			default:
				break;
		}

		wgt.needs_send = false;
		wgt.sent = true;
	}
}

// ---------------------------------------------------------------------------
// inbound events
// ---------------------------------------------------------------------------

void WindowManager::HandleHello(uint16_t dll_version, uint32_t caps)
{
	if (!m_client) {
		return;
	}

	m_capable = true;
	m_dll_version = dll_version;
	m_caps = caps;

	LogInfo("[NMSWindow] client [{}] hello: dll version [{}] caps [{:#x}]", m_client->GetName(), dll_version, caps);
}

void WindowManager::HandleEvent(uint8_t kind, uint32_t window_id, uint16_t action, uint32_t value, const std::string& text)
{
	if (!m_client || kind < EventButton || kind > EventCanvas) {
		return;
	}

	if (!ConsumeEventBudget()) {
		return;
	}

	// a player-close removes the window before scripts run; everything else
	// requires a live window owned by this client
	Window* win = FindWindow(static_cast<int>(window_id));
	if (!win) {
		return;
	}

	// disabled buttons never fire (matched by the script's action number)
	if (kind == EventButton) {
		for (const auto& wgt : win->widgets) {
			if (wgt.kind == WidgetButton && wgt.action == action) {
				if (wgt.disabled) {
					return;
				}
				break;
			}
		}
	}

	if (kind == EventClosed && value == 1) {
		DispatchToScripts(kind, win, action, value, text);
		Close(static_cast<int>(window_id));
		return;
	}

	// Nautilus Vault panels are engine-driven: their events map onto the vault
	// handlers instead of the script event stream.
	if (win->key.rfind("vault_", 0) == 0) {
		NmsVaultOnWindowEvent(m_client, kind, action, value, window_id);
		return;
	}

	DispatchToScripts(kind, win, action, value, text);
}

// One-shot local action outside the widget model. Action 1 opens the native
// bank window client-side (the bank UI is not server-drawable).
bool WindowManager::SendLocalAction(int window_id, int action)
{
	Window* win = FindWindow(window_id);
	if (!win || !m_client || !m_capable) {
		return false;
	}

	Buf b;
	b.U8(MSG_LOCALACTION);
	b.U32(win->id);
	b.U16(static_cast<uint16_t>(action));
	SendBuf(m_client, b);
	return true;
}

void WindowManager::DispatchToScripts(uint8_t kind, const Window* win, uint16_t action, uint32_t value, const std::string& text)
{
	if (!parse || !m_client) {
		return;
	}

	// data protocol: "window_id|kind|action|value|text" (text may contain '|')
	std::string data = fmt::format("{}|{}|{}|{}|{}",
		win ? win->id : 0, kind, action, value, text);

	// route to the owning NPC's script while that NPC lives and has the sub,
	// otherwise fall to the player script
	NPC* owner = nullptr;
	if (win && win->owner_entity_id) {
		Mob* mob = entity_list.GetMob(win->owner_entity_id);
		if (mob && mob->IsNPC() && mob->CastToNPC()->GetNPCTypeID() == win->owner_npc_type_id) {
			owner = mob->CastToNPC();
		}
	}

	if (owner && parse->HasQuestSub(owner->GetNPCTypeID(), EVENT_NMS_WINDOW)) {
		parse->EventNPC(EVENT_NMS_WINDOW, owner, m_client, data, 0);
		return;
	}

	if (parse->PlayerHasQuestSub(EVENT_NMS_WINDOW)) {
		parse->EventPlayer(EVENT_NMS_WINDOW, m_client, data, 0);
	}
}

void WindowManager::RemoveTicker(Window& win)
{
	if (!win.is_ticker) {
		return;
	}

	win.is_ticker = false;
	if (m_tickers > 0) {
		m_tickers--;
	}
	if (zone && zone->NmsTickerWindows() > 0) {
		zone->NmsTickerWindowsAdd(-1);
	}
}

void WindowManager::ServerCloseAll()
{
	// player is zoning out / camping / disconnecting: tell scripts (kind 4,
	// value 2 = server closed), then drop all state
	std::vector<uint32_t> ids;
	ids.reserve(m_windows.size());
	for (auto& win : m_windows) {
		ids.push_back(win.id);
	}

	for (uint32_t id : ids) {
		Window* win = FindWindow(static_cast<int>(id));
		if (win) {
			DispatchToScripts(EventClosed, win, 0, 2, std::string());
		}
	}

	if (m_tickers && zone) {
		zone->NmsTickerWindowsAdd(-static_cast<int>(m_tickers));
		m_tickers = 0;
	}

	m_windows.clear();
}

// ---------------------------------------------------------------------------
// per-client registry + packet entry points
// ---------------------------------------------------------------------------

namespace {

std::unordered_map<Client*, std::unique_ptr<WindowManager>>& Registry()
{
	static std::unordered_map<Client*, std::unique_ptr<WindowManager>> s_windows;
	return s_windows;
}

} // namespace

namespace EQ::NMS {

WindowManager& GetWindows(Client* c)
{
	auto& entry = Registry()[c];
	if (!entry) {
		entry = std::make_unique<WindowManager>(c);
	}
	return *entry;
}

void NmsWindowOnClientDestroy(Client* c)
{
	// Client destructor hook: tell scripts their windows are going away
	// (kind 4, value 2) while the client is still dispatchable, then free.
	auto& entry = Registry();
	auto it = entry.find(c);
	if (it != entry.end()) {
		it->second->ServerCloseAll();
		entry.erase(it);
	}
}

void NmsWindowHandlePacket(Client* c, const EQApplicationPacket* app)
{
	if (!c || !app || app->size < 1) {
		return;
	}

	const uint8_t* d = app->pBuffer;
	uint8_t type = d[0];
	LogInfo("[NMSWindow] packet from [{}]: type [{}] size [{}]", c->GetName(), type, app->size);

	if (type == 1) {
		// HELLO: u16 dll_version, u32 caps
		if (app->size < 7) {
			return;
		}
		uint16_t version = static_cast<uint16_t>(d[1]) | (static_cast<uint16_t>(d[2]) << 8);
		uint32_t caps = static_cast<uint32_t>(d[3]) | (static_cast<uint32_t>(d[4]) << 8) |
						(static_cast<uint32_t>(d[5]) << 16) | (static_cast<uint32_t>(d[6]) << 24);
		GetWindows(c).HandleHello(version, caps);
		return;
	}

	if (type == 2) {
		// EVENT: u32 window_id, u8 kind, u16 action, u32 value, u8 len + text
		if (app->size < 14) {
			return;
		}
		uint32_t window_id = static_cast<uint32_t>(d[1]) | (static_cast<uint32_t>(d[2]) << 8) |
							 (static_cast<uint32_t>(d[3]) << 16) | (static_cast<uint32_t>(d[4]) << 24);
		uint8_t kind = d[5];
		uint16_t action = static_cast<uint16_t>(d[6]) | (static_cast<uint16_t>(d[7]) << 8);
		uint32_t value = static_cast<uint32_t>(d[8]) | (static_cast<uint32_t>(d[9]) << 8) |
						 (static_cast<uint32_t>(d[10]) << 16) | (static_cast<uint32_t>(d[11]) << 24);
		uint8_t text_len = d[12];
		if (app->size < static_cast<uint32_t>(13 + text_len)) {
			return;
		}
		std::string text(reinterpret_cast<const char*>(d + 13), text_len);
		GetWindows(c).HandleEvent(kind, window_id, action, value, text);
	}
}

} // namespace EQ::NMS
