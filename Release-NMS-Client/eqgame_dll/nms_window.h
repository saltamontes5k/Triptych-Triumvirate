#pragma once
// NMS script windows (arcade) -- client half.
//
// Receives OP_NMSWindowData 0x140A (open/close/widgets/canvas frames), renders
// each window as a bare SIDL shell (drag + native closebox) with all content
// drawn through the d3d9 EndScene hook (same path as FloatingTextManager), and
// sends player input back via OP_NMSWindowEvent 0x140B. The server-side engine
// and the full wire contract live in Release-NMS-Server/zone/nms_window.h.
//
// Client-side simplifications versus the NMS ancestor: window content is laid
// out and fitted into the shell's actual rect (the wire's w/h is advisory),
// icons draw as tinted quads with the icon id (no icon-atlas hook yet), and
// rounded corners draw square.

#include <d3d9.h>
#include <d3dx9.h>

#include <list>
#include <map>
#include <string>
#include <vector>

#define NMSW_OP_DATA  0x140A
#define NMSW_OP_EVENT 0x140B

#define NMSW_DLL_VERSION 2
#define HELLO_INTERVAL_MS 5000
#define NMSW_CAP_WINDOWS 1

// widget kinds (server nms_window.h WidgetKind)
enum NMSWWidgetKind {
	NMSW_HEADER   = 1,
	NMSW_TEXT     = 2,
	NMSW_SEP      = 3,
	NMSW_SAMELINE = 4,
	NMSW_BUTTON   = 5,
	NMSW_TABLE    = 6,
	NMSW_PROGRESS = 7,
	NMSW_INPUT    = 8,
	NMSW_ICON     = 9,
	NMSW_ITEMLINK = 10,
	NMSW_CANVAS   = 11,
};

// canvas piece types (server PieceType)
enum NMSWPiece {
	NMSWP_PANEL     = 1,
	NMSWP_RECT      = 2,
	NMSWP_GRID      = 3,
	NMSWP_LINE      = 4,
	NMSWP_RING      = 5,
	NMSWP_TEXT      = 6,
	NMSWP_BANNER    = 7,
	NMSWP_LABEL     = 8,
	NMSWP_CLICKABLE = 9,
	NMSWP_ICON      = 10, // rect (x,y,a=width,b=height), aux = item icon id; text = fallback label
};

// window flags
#define NMSW_F_NORESIZE    0x01
#define NMSW_F_CAPTUREKEYS 0x02
#define NMSW_F_NOCLOSE     0x04
#define NMSW_F_POPOUT      0x08
#define NMSW_F_AUTOSIZE    0x10
#define NMSW_F_TICKER      0x20
#define NMSW_F_NOTITLEBAR  0x40

// event kinds (server WindowEventKind)
#define NMSW_EV_BUTTON 1
#define NMSW_EV_KEY    2
#define NMSW_EV_INPUT  3
#define NMSW_EV_CLOSED 4
#define NMSW_EV_GRID   5
#define NMSW_EV_CANVAS 6

// key values for kind-2 events
#define NMSW_KEY_UP     1
#define NMSW_KEY_DOWN   2
#define NMSW_KEY_LEFT   3
#define NMSW_KEY_RIGHT  4
#define NMSW_KEY_SPACE  5
#define NMSW_KEY_ENTER  6
#define NMSW_KEY_ESCAPE 7

namespace EQClasses {
class CXWnd;
}

namespace NMSWin {

struct Piece {
	uint8_t type = 0;
	int16_t x = 0, y = 0, a = 0, b = 0;
	uint32_t argb = 0;
	uint16_t aux = 0, aux2 = 0, aux3 = 0;
	std::string text;
	std::vector<std::pair<uint16_t, uint32_t>> grid; // GridP only
};

struct Widget {
	uint8_t kind = NMSW_HEADER;
	bool same_line = false;
	bool wrap = false;
	uint32_t argb = 0xFFFFFFFF;
	std::string text;
	uint16_t action = 0;
	bool disabled = false;
	float fraction = 0.f;
	uint32_t icon_id = 0;
	uint8_t size = 32;
	uint32_t item_id = 0;
	uint8_t cols = 1;
	std::vector<std::string> cells;
	uint16_t cw = 0, ch = 0;
	std::vector<Piece> pieces;
	// layout cache (window space)
	int lx = 0, ly = 0, lw = 0, lh = 0;
	bool placed = false;
};

struct HitRegion {
	int x = 0, y = 0, r = 0, b = 0; // window space (canvas pieces already scaled)
	uint8_t kind = 0;               // event kind on click
	uint16_t action = 0;
	uint8_t grid_cols = 0;          // GridP
	int cell_w = 1, cell_h = 1;     // GridP, scaled
};

struct ArcadeWindow {
	uint32_t id = 0;
	std::string key, title;
	uint16_t w = 200, h = 100;
	uint32_t flags = 0;
	uint32_t style_bg = 0;
	uint32_t style_border = 0;
	uint8_t style_rounding = 0, style_border_px = 0;
	std::vector<Widget> widgets;
	EQClasses::CXWnd* shell = nullptr;
	EQClasses::CXWnd* close_btn = nullptr;
	bool relayout_needed = true;
	int active_input = -1;          // widget index of the focused input
	std::string input_buffer;
	bool closed_event_sent = false;
	bool frame_logged = false;      // one-shot diagnostics
	bool draw_logged = false;
	bool click_logged = false;
	bool drop_logged = false;       // a canvas frame arrived for a missing widget
	bool frame_size_logged = false; // first FitShell application
	bool frame_reset_logged = false;// rect was reset behind FitShell
	int fit_h = 0;                  // height the laid-out content needs (see Relayout)
	DWORD last_click_ms = 0;        // de-dupes XWM_LCLICK vs XWM_LMOUSEUP
	int msg_log = 0;                // one-shot trace of unhandled notifications
	std::vector<HitRegion> hits;
};

class Manager {
public:
	static Manager& Get();

	void OnPacket(void* buf, size_t size);        // 0x140A from the world stream
	void SendHello();                             // capability HELLO (idempotent, re-sent)
	void SendEvent(uint32_t id, uint8_t kind, uint16_t action, uint32_t value, const std::string& text);
	void Render();                                // EndScene hook
	void OnGameState(DWORD state);                // zoning: drop everything silently
	void OnDeviceReset() { KillDevice(); }        // d3d device lost/reset
	bool KeyCaptureActive() const;                // a capture-flags window is open
	bool FeedKey(uint32_t dik_offset, bool down); // true = consumed (suppress)

private:
	Manager() = default;

	void KillDevice();
	void EnsureShell(ArcadeWindow& win);
	void DestroyShell(ArcadeWindow& win);
	void Relayout(ArcadeWindow& win);
	void FitShell(ArcadeWindow& win);                 // frame = requested w/h + chrome
	void SendClosed(ArcadeWindow& win);
	bool ClickWindow(ArcadeWindow& win, int sx, int sy); // screen-space hit test

	// draw helpers (device space = window origin + offsets)
	void FillRect(int x, int y, int w, int h, uint32_t argb);
	void DrawLine(int x1, int y1, int x2, int y2, uint32_t argb, float width);
	void DrawRing(int cx, int cy, float radius, uint32_t argb, float width);
	void DrawTextStr(int x, int y, const std::string& s, uint32_t argb, int size, int align, int clip_w);
	int  TextWidth(const std::string& s, int size);
	int  TextHeightWrapped(const std::string& s, int size, int width);
	void DrawWrapped(int x, int y, int width, const std::string& s, uint32_t argb);
	// This client's d3dx9 font object is createable but dead: every DrawText
	// (measuring or drawing) returns 0, so text is rasterised through GDI into
	// a cached A8R8G8B8 texture and blitted with the sprite instead.
	HDC  GdiDC();
	HFONT GdiFont(int size);
	IDirect3DTexture9* GetTextTexture(const std::string& s, int size, int& out_w, int& out_h);
	void SetScissor(const RECT& rc);
	void ClearScissor();
	// item icon from <eqdir>\ItemIcons\<id>.png (loaded through D3DX, cached);
	// missing art renders the fallback text instead
	IDirect3DTexture9* GetIconTexture(uint32_t icon_id);
	void DrawIcon(int x, int y, int w, int h, uint32_t icon_id, const std::string& fallback_text);

	// list, not vector: shells keep an ArcadeWindow* and a reallocation on the
	// second window would leave those pointers dangling inside the UI callbacks
	std::list<ArcadeWindow> m_wins;
	uint32_t m_next_id = 1;
	bool m_hello_sent = false;      // capability chat announced
	DWORD m_next_hello = 0;         // capability heartbeat (see SendHello)
	bool m_lbutton_down = false;    // physical LMB edge detect for the click poll
	bool m_press_logged = false;    // one-shot proof the poll is running

	// d3d resources
	IDirect3DDevice9* m_dev = nullptr;
	bool m_dev_ok = false;
	IDirect3DTexture9* m_white = nullptr;
	ID3DXSprite* m_sprite = nullptr;
	ID3DXLine* m_line = nullptr;
	HDC m_dc = nullptr;                    // measured/rasterised text goes here
	HFONT m_hfont14 = nullptr;
	HFONT m_hfont18 = nullptr;
	struct TextTex {
		IDirect3DTexture9* tex = nullptr;
		int w = 0, h = 0;
	};
	std::map<std::pair<int, std::string>, TextTex> m_text_tex; // glyph atlas per string
	std::map<uint32_t, IDirect3DTexture9*> m_icon_tex; // failures cached as nullptr
	int m_ofs_x = 0, m_ofs_y = 0; // window origin in screen space (current)
	ArcadeWindow* m_cur = nullptr;

	friend class ArcadeShellWnd;
};

} // namespace NMSWin
