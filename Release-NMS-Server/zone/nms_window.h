/* NMS windows: the script-drawn client window engine behind the arcade.
 *
 * Quest scripts (Lua and Perl) open windows on a player's client with
 * NMSWindowOpen, populate them with widgets (headers, text, buttons, tables,
 * progress bars, input boxes, icons, item links, canvases), and receive the
 * player's clicks/keys/typing back as EVENT_NMS_WINDOW / event_nms_window.
 * Clients running the patched dinput8.dll render the real windows; every
 * other client gets the documented plain-text chat fallback.
 *
 * Wire contract (this file is the server half):
 *   S2C OP_NMSWindowData 0x140A -- stream of little-endian messages packed by
 *     NMSWindowSend, one packet per call:
 *       MSG_OPEN    u8=1  u32 id, str key, str title, u16 w, u16 h, u8 flags
 *       MSG_CLOSE   u8=2  u32 id
 *       MSG_CLEAR   u8=3  u32 id
 *       MSG_WIDGET  u8=4  u32 id, u16 index, u8 kind, u8 sameline, payload*
 *       MSG_SETWID  u8=5  u32 id, u16 index, u8 kind, payload*  (in-place update)
 *       MSG_STYLE   u8=6  u32 id, u32 bg, u32 border, u8 rounding, u8 border_px
 *       MSG_FRAME   u8=7  u32 id, u16 index, u16 count, pieces*  (canvas draw)
 *   *str = u16 byte length + raw UTF-8 bytes. Payloads per widget kind:
 *       HEADER/TEXT     u32 argb, u8 wrap, str text
 *       SEPARATOR       (none)
 *       SAMELINE        (none)
 *       BUTTON          str label, u32 argb (0 = normal), u16 action, u8 disabled
 *       TABLE           u8 cols, u16 cell_count, cell_count * str
 *       PROGRESS        f32 fraction, str overlay
 *       INPUT           u16 action, u8 maxlen, str text
 *       ICON            u32 icon_id, u8 size
 *       ITEMLINK        u32 item_id, str name
 *       CANVAS          u16 cw, u16 ch
 *   canvas piece (MSG_FRAME entry), 19 bytes + optional payload:
 *       u8 type, i16 x, i16 y, i16 a, i16 b, u32 argb, u16 aux, u16 aux2, u16 aux3
 *       PanelP  rect, argb fill, aux rounding, aux2 border px (gold edge)
 *       RectP   rect, argb fill/border, aux rounding (0 = square)
 *       GridP   topleft (x,y), a cell w, b cell h, aux cols, aux2 rows,
 *               aux3 click action (0 = none),
 *               then u16 filled, filled * (u16 cell_index, u32 argb)
 *       LineP   (x,y)-(a,b), argb, aux width
 *       RingP   center (x,y), a radius, argb, aux width
 *       TextP   (x,y), argb, aux font size (0 = default), aux2 align 0/1/2, str
 *       BannerP (y used), argb, aux size, aux2 pulse, str
 *       LabelP  rect (pill), argb, str
 *       ClickP  rect, aux action (invisible hit region -> kind 6 events)
 *
 *   C2S OP_NMSWindowEvent 0x140B:
 *       HELLO u8=1  u16 dll_version, u32 caps   -- client announces window support
 *       EVENT u8=2  u32 window_id, u8 kind, u16 action, u32 value, str text
 *       event kinds: 1 button, 2 key, 3 input enter, 4 closed (value 1 player /
 *         2 server), 5 grid click (value cell index), 6 canvas click
 *       key values: 1 up, 2 down, 3 left, 4 right, 5 space, 6 enter, 7 escape,
 *         else uppercase ASCII of the letter/digit pressed
 *
 * Script limits match the published arcade manual and live in ruletypes.h
 * under Custom:NMSWindow*. */
#pragma once

#include "../common/types.h"

#include <memory>
#include <string>
#include <vector>

class Client;
class Mob;
class EQApplicationPacket;

namespace EQ::NMS {

enum WidgetKind : uint8 {
	WidgetHeader   = 1,
	WidgetText     = 2,
	WidgetSep      = 3,
	WidgetSameLine = 4,
	WidgetButton   = 5,
	WidgetTable    = 6,
	WidgetProgress = 7,
	WidgetInput    = 8,
	WidgetIcon     = 9,
	WidgetItemLink = 10,
	WidgetCanvas   = 11,
};

enum PieceType : uint8 {
	PiecePanel    = 1,
	PieceRect     = 2,
	PieceGrid     = 3,
	PieceLine     = 4,
	PieceRing     = 5,
	PieceText     = 6,
	PieceBanner   = 7,
	PieceLabel    = 8,
	PieceClickable = 9,
	// rect (x,y) size (a,b), aux = item icon id, text = fallback label when the
	// client has no art for it (ItemIcons\<id>.png)
	PieceIcon     = 10,
};

enum WindowFlagBits : uint32 {
	WFNoResize     = 1,
	WFCaptureKeys  = 2,
	WFNoClose      = 4,
	WFPopout       = 8,
	WFAutoSize     = 16,
	WFTicker       = 32,
	WFNoTitleBar   = 64,
};

enum WindowEventKind : uint8 {
	EventButton = 1,
	EventKey    = 2,
	EventInput  = 3,
	EventClosed = 4,
	EventGrid   = 5,
	EventCanvas = 6,
};

enum KeyValue : uint32 {
	KeyUp     = 1,
	KeyDown   = 2,
	KeyLeft   = 3,
	KeyRight  = 4,
	KeySpace  = 5,
	KeyEnter  = 6,
	KeyEscape = 7,
};

struct Widget {
	WidgetKind kind = WidgetHeader;
	bool same_line = false;
	bool wrap = false;
	uint32 argb = 0;
	std::string text;        // header/text/button label/overlay/input content/item name
	uint16 action = 0;
	bool disabled = false;
	float fraction = 0.f;
	uint32 icon_id = 0;
	uint8 icon_size = 32;
	uint32 item_id = 0;
	uint8 cols = 1;
	std::vector<std::string> cells;
	uint16 cw = 0;           // canvas size
	uint16 ch = 0;
	std::string frame_buf;   // packed pieces awaiting Send (no count prefix)
	uint16 frame_count = 0;
	bool frame_dirty = false;
	bool needs_send = true;  // dirty flag for delta sends
	bool sent = false;       // client holds this widget (delta bookkeeping)
};

struct Window {
	uint32 id = 0;
	std::string key;
	std::string title;
	uint16 w = 200;
	uint16 h = 100;
	uint32 flags = 0;
	bool sent_full = false;      // client has the current widget set
	bool style_dirty = false;
	uint32 style_bg = 0;
	uint32 style_border = 0;
	uint8 style_rounding = 0;
	uint8 style_border_px = 0;
	std::vector<Widget> widgets;
	bool is_ticker = false;
	// owner: the NPC whose script opened the window (empty when the player
	// script opened it); events route there while the NPC lives
	uint16 owner_entity_id = 0;
	uint32 owner_npc_type_id = 0;
	// fallback chat bookkeeping
	bool fallback_rendered = false;
};

// Per-client window state. The Client owns one of these (lazily created).
class WindowManager {
public:
	explicit WindowManager(Client* c);
	~WindowManager();

	// ---- script surface (mirrors the arcade manual API) ----
	int  Open(const std::string& key, const std::string& title, int w, int h, int flags);
	bool Close(int window_id);   // script-called close: no close event
	bool Clear(int window_id);   // drop all widgets, reset indexes/layout
	bool IsOpen(int window_id) const;
	bool IsSupported() const;
	bool Capable() const { return m_capable; }
	uint16_t DllVersion() const { return m_dll_version; }
	bool Send(int window_id);    // false = rate limited, changes stay queued
	// one-shot server->client local action (u8=8, u32 id, u16 action) outside the
	// widget model; action 1 = open the native bank window (vault panel)
	bool SendLocalAction(int window_id, int action);

	int  AddHeader(int window_id, const std::string& text, const std::string& color);
	int  AddText(int window_id, const std::string& text, const std::string& color, bool wrap);
	int  AddSeparator(int window_id);
	int  AddSameLine(int window_id);
	int  AddButton(int window_id, const std::string& label, int action, const std::string& color);
	bool SetButton(int window_id, int widget, const std::string& label, const std::string& color, bool disabled);
	int  AddTable(int window_id, const std::vector<std::string>& headers, const std::vector<std::vector<std::string>>& rows);
	// flat packed variant for script bindings: headers + row cells in one
	// 0x1F-separated string, cols columns per row
	int  AddTablePacked(int window_id, int cols, const std::string& packed);
	int  AddProgress(int window_id, double fraction, const std::string& color, const std::string& overlay);
	bool SetProgress(int window_id, int widget, double fraction, const std::string& overlay);
	int  AddInput(int window_id, int action, int maxlen, const std::string& text);
	bool SetText(int window_id, int widget, const std::string& text);
	int  AddIcon(int window_id, int icon_id, int size);
	int  AddItemLink(int window_id, int item_id);
	bool SetStyle(int window_id, const std::string& bg, const std::string& border, int rounding, int border_px);
	int  AddCanvas(int window_id, int cw, int ch);
	// canvas frames: begin clears the pending frame; pieces accumulate until
	// the next Send flushes them as one MSG_FRAME. Bindings pass specs as CSV
	// ("type,x,y,a,b,argb,aux,aux2,aux3,text" / "x,y,cols,rows,cellw,cellh,action")
	// to stay under luabind's arity ceiling.
	bool BeginCanvasFrame(int window_id, int widget);
	bool AddCanvasPieceCSV(int window_id, int widget, const std::string& spec);
	bool AddCanvasGridCSV(int window_id, int widget, const std::string& spec, const std::string& packed_colors);
	bool AddCanvasPiece(int window_id, int widget, int type, int x, int y, int a, int b,
		uint32_t argb, int aux, int aux2, int aux3, const std::string& text);
	// packed_colors: "cell_index,color_argb" entries joined by 0x1F
	bool AddCanvasGrid(int window_id, int widget, int x, int y, int cols, int rows,
		int cellw, int cellh, int action, const std::string& packed_colors);

	// ---- wire handlers (called from client_packet.cpp) ----
	void HandleHello(uint16 dll_version, uint32 caps);
	void HandleEvent(uint8 kind, uint32 window_id, uint16 action, uint32 value, const std::string& text);

	// ---- lifecycle ----
	// Zone-out / camp / disconnect: emits kind-4 value-2 close events for
	// scripts, then clears all window state. Called before the client is torn
	// down, never from inside the destructor.
	void ServerCloseAll();

	// zone-wide ticker budget accounting
	uint32 TickerCount() const { return m_tickers; }

private:
	Window* FindWindow(int window_id);
	Window* OpenWindowLocked(const std::string& key, const std::string& title, int w, int h, int flags);
	bool ConsumeSendBudget();
	bool ConsumeEventBudget();
	void SerializeWidget(std::vector<uint8>& buf, uint8 msg, const Window& win, const Widget& wgt) const;
	void FallbackRender(Window& win);
	void DispatchToScripts(uint8 kind, const Window* win, uint16 action, uint32 value, const std::string& text);
	void RemoveTicker(Window& win);

	Client* m_client;
	uint32 m_next_id = 1;
	std::vector<Window> m_windows;
	uint32 m_tickers = 0;
	uint32 m_packets_this_sec = 0;
	uint32 m_events_this_sec = 0;
	uint32 m_budget_sec = 0;
	bool m_capable = false;      // patched dll announced itself (HELLO)
	uint16_t m_dll_version = 0;
	uint32_t m_caps = 0;
};

// Color names/strings/ints -> ARGB. Returns def when unparseable; "none" -> 0.
uint32 ParseWindowColor(const std::string& color, uint32 def);

// Per-client manager access (created lazily; freed in NmsWindowOnClientDestroy).
WindowManager& GetWindows(Client* c);

// Called from Client's destructor hook: server-closed events for scripts,
// then state teardown. Never dispatches into a partially destroyed Client.
void NmsWindowOnClientDestroy(Client* c);

// OP_NMSWindowEvent 0x140B entry point (hello + input events), called from
// the opcode dispatcher in client_packet.cpp.
void NmsWindowHandlePacket(Client* c, const EQApplicationPacket* app);

} // namespace EQ::NMS
