#include "waypoint_window.h"

#pragma pack(push, 1)
struct WaypointListEntry_Struct {
    int32_t category_id;
    int32_t waypoint_id;
    uint8_t enabled;
    char name[64];
};

struct WaypointList_Struct {
    bool group_enabled;
    bool expedition_enabled;
    bool group_selected;
    bool force_show;
    bool autoconfirm_selected;
    uint32_t entry_count;
    WaypointListEntry_Struct entries[1]; 
};

struct WaypointRequest_Struct {
    int32_t waypoint_id;
    bool    expedition_selected;
    bool    group_selected;
    bool    autoconfirm_selected;
};
#pragma pack(pop)

extern VOID SendEQMessage(DWORD PacketType, PVOID pData, DWORD Length);
extern void AddXMLFile(const char *filename);
extern CXWnd *FindMQ2Window(PCHAR WindowName);

WaypointsWnd* WaypointsWnd::s_instance = nullptr;

WaypointsWnd* WaypointsWnd::GetInstance() {
    return s_instance;
}

WaypointsWnd::WaypointsWnd() : CCustomWnd("WaypointsWnd") {
    // WriteChatf("[Waypoints] Creating WaypointsWnd...");
    
    m_pContinentsList = (CListWnd*)GetChildItem("ContinentsList");
    m_pWaypointsList = (CListWnd*)GetChildItem("WaypointsList");
    m_pTravelButton = (CButtonWnd*)GetChildItem("SelectedWaypointButton");
    m_pExpeditionButton = (CButtonWnd*)GetChildItem("MyExpeditionButton");
    m_pGroupCheckbox = (CButtonWnd*)GetChildItem("GroupCheckbox");
    m_pAutoAcceptCheckbox = (CButtonWnd*)GetChildItem("AutoAcceptCheckbox");
    m_pPortGroupLabel = (CXWnd*)GetChildItem("PortGroupLabel");
    m_pAutoAcceptLabel = (CXWnd*)GetChildItem("AutoAcceptLabel");

    if (!m_pContinentsList) WriteChatf("[Waypoints] Failed to find ContinentsList!");
    if (!m_pWaypointsList) WriteChatf("[Waypoints] Failed to find WaypointsList!");
    if (!m_pTravelButton) WriteChatf("[Waypoints] Failed to find SelectedWaypointButton!");

    // Hook the WndNotification function into the vtable
    SetWndNotification(WaypointsWnd);

    // Initialize Categories (0-based indexing)
    m_categories[0] = "Antonica";
    m_categories[1] = "Faydwer";
    m_categories[2] = "Odus";
    m_categories[3] = "Kunark";
    m_categories[4] = "Velious";
    m_categories[5] = "Luclin";
    m_categories[6] = "The Planes";
    m_categories[7] = "Discord";
    m_categories[8] = "Special";
    
    // WriteChatf("[Waypoints] WaypointsWnd created.");
}

WaypointsWnd::~WaypointsWnd() {
    // WriteChatf("[Waypoints] Destroying WaypointsWnd.");
}

void WaypointsWnd::Initialize() {
    AddXMLFile("NMS_WaypointsWnd.xml");
}

void WaypointsWnd::Shutdown() {
    if (s_instance) {
        ((CXWnd*)s_instance)->Show(false, false);
        delete s_instance;
        s_instance = nullptr;
    }
}

void WaypointsWnd::OnIncomingPacket(uint16_t opcode, void* buf, size_t size) {
    if (opcode == 0x1402) {
        // WriteChatf("[Waypoints] Received Waypoint List (Size: %u)", size);
        
        if (!pSidlMgr->FindScreenPieceTemplate("WaypointsWnd")) {
            WriteChatf("[Waypoints] Template 'WaypointsWnd' not found! UI reload may be needed.");
            return;
        }

        if (!s_instance) {
            s_instance = new WaypointsWnd();
        }
        
        if (s_instance) {
            s_instance->HandleWaypointList(buf, size);
            ((CXWnd*)s_instance)->Show(true, true);
        }
    }
}

bool WaypointsWnd::OnOutgoingPacket(uint16_t opcode, void* buf, size_t size) {
    return false;
}

void WaypointsWnd::OnPulse() {
}

void WaypointsWnd::HandleWaypointList(void* buf, size_t size) {
    if (size < (sizeof(WaypointList_Struct) - sizeof(WaypointListEntry_Struct))) {
        WriteChatf("[Waypoints] Packet too small for WaypointList header!");
        return;
    }

    WaypointList_Struct* wl = (WaypointList_Struct*)buf;
    
    size_t expected_size = (sizeof(WaypointList_Struct) - sizeof(WaypointListEntry_Struct)) + (wl->entry_count * sizeof(WaypointListEntry_Struct));
    if (size < expected_size) {
        WriteChatf("[Waypoints] Packet too small for %u entries (Expected: %u, Got: %u)", wl->entry_count, expected_size, size);
        return;
    }

    m_waypoints.clear();

    for (uint32_t i = 0; i < wl->entry_count; i++) {
        WaypointData wp;
        wp.id = wl->entries[i].waypoint_id;
        wp.category_id = wl->entries[i].category_id;
        wp.enabled = (wl->entries[i].enabled != 0);
        
        // Safe string copy
        memset(wp.name, 0, sizeof(wp.name));
        strncpy(wp.name, wl->entries[i].name, sizeof(wp.name) - 1);
        
        m_waypoints.push_back(wp);
    }

    // WriteChatf("[Waypoints] Loaded %u waypoints.", m_waypoints.size());

    // Write Checked directly rather than calling CButtonWnd::SetCheck(). SetCheck is a
    // FUNCTION_AT_ADDRESS import (0x54FBE0) that these two lines were the only callers of
    // anywhere in the DLL, and it does not take -- the server's state arrived correctly but
    // the boxes always rendered clear, so the settings looked like they never saved. Reading
    // Checked has always worked (WndNotification below reports the right state), and the rest
    // of the DLL sets it directly too (see MQ2AdvDps.cpp), so use the member the same way.
    if (m_pGroupCheckbox) {
        m_pGroupCheckbox->Checked = wl->group_selected ? 1 : 0;
        ((PCSIDLWND)m_pGroupCheckbox)->Enabled = wl->group_enabled ? 1 : 0;
        if (m_pPortGroupLabel) {
            ((PCSIDLWND)m_pPortGroupLabel)->Enabled = wl->group_enabled ? 1 : 0;
        }
    }
    if (m_pAutoAcceptCheckbox) {
        m_pAutoAcceptCheckbox->Checked = wl->autoconfirm_selected ? 1 : 0;
    }
    if (m_pExpeditionButton) {
        ((PCSIDLWND)m_pExpeditionButton)->Enabled = wl->expedition_enabled ? 1 : 0;
    }
    
    PopulateContinents();
}

void WaypointsWnd::PopulateContinents() {
    if (!m_pContinentsList) return;
    m_pContinentsList->DeleteAll();

    std::set<int32_t> active_categories;
    for (size_t i = 0; i < m_waypoints.size(); i++) {
        active_categories.insert(m_waypoints[i].category_id);
    }

    // WriteChatf("[Waypoints] Populating %u continents.", active_categories.size());

    for (std::set<int32_t>::iterator it = active_categories.begin(); it != active_categories.end(); ++it) {
        int32_t cat_id = *it;
        std::string name = m_categories.count(cat_id) ? m_categories[cat_id] : "Unknown";
        
        // Add item with White color (0xFFFFFFFF)
        int index = m_pContinentsList->AddString(name.c_str(), 0xFFFFFFFF, (uint32_t)cat_id, 0);
        
        // Also set text for column 1 just in case column 0 is hidden
        CXStr szName(name.c_str());
        m_pContinentsList->SetItemText(index, 1, &szName);
        
        m_pContinentsList->SetItemData(index, (uint32_t)cat_id);
        
        // WriteChatf("[Waypoints] Added continent: %s (ID: %d) at index %d", name.c_str(), cat_id, index);
    }
    
    if (m_pContinentsList->Items > 0) {
        m_pContinentsList->SetCurSel(0);
        int32_t first_cat = (int32_t)m_pContinentsList->GetItemData(0);
        // WriteChatf("[Waypoints] Selecting first continent (ID: %d)", first_cat);
        PopulateWaypoints(first_cat);
    }
}

void WaypointsWnd::PopulateWaypoints(int category_id) {
    if (!m_pWaypointsList) return;
    m_pWaypointsList->DeleteAll();

    int added_count = 0;
    for (size_t i = 0; i < m_waypoints.size(); i++) {
        const WaypointData& wp = m_waypoints[i];
        if (wp.category_id == category_id) {
            // Add with White color
            int index = m_pWaypointsList->AddString(wp.name, 0xFFFFFFFF, (uint32_t)wp.id, 0);
            
            // Set text for column 1
            CXStr szName(wp.name);
            m_pWaypointsList->SetItemText(index, 1, &szName);
            
            m_pWaypointsList->SetItemData(index, (uint32_t)wp.id);
            
            if (!wp.enabled) {
                m_pWaypointsList->SetItemColor(index, 1, 0xFFA0A0A0);
            }
            added_count++;
        }
    }
    // WriteChatf("[Waypoints] Populated %d waypoints for category %d.", added_count, category_id);
}

int WaypointsWnd::WndNotification(CXWnd* pWnd, unsigned int Message, void* data) {
    if (Message == XWM_LCLICK) {
        if (m_pContinentsList && pWnd == (CXWnd*)m_pContinentsList) {
            int sel = m_pContinentsList->GetCurSel();
            if (sel != -1) {
                PopulateWaypoints((int)m_pContinentsList->GetItemData(sel));
            }
        }
        else if (m_pTravelButton && pWnd == (CXWnd*)m_pTravelButton) {
            if (m_pWaypointsList) {
                int sel = m_pWaypointsList->GetCurSel();
                if (sel != -1) {
                    uint32_t wp_id = (uint32_t)m_pWaypointsList->GetItemData(sel);
                    WaypointRequest_Struct req;
                    memset(&req, 0, sizeof(req));
                    req.waypoint_id = wp_id;
                    req.group_selected = m_pGroupCheckbox ? (m_pGroupCheckbox->Checked != 0) : false;
                    req.autoconfirm_selected = m_pAutoAcceptCheckbox ? (m_pAutoAcceptCheckbox->Checked != 0) : false;
                    
                    SendEQMessage(0x1403, &req, sizeof(req));
                    ((CXWnd*)this)->Show(false, false);
                }
            }
        }
        else if (m_pExpeditionButton && pWnd == (CXWnd*)m_pExpeditionButton) {
            WaypointRequest_Struct req;
            memset(&req, 0, sizeof(req));
            req.waypoint_id = 0; 
            req.expedition_selected = true;
            req.group_selected = m_pGroupCheckbox ? (m_pGroupCheckbox->Checked != 0) : false;
            req.autoconfirm_selected = m_pAutoAcceptCheckbox ? (m_pAutoAcceptCheckbox->Checked != 0) : false;
            
            SendEQMessage(0x1403, &req, sizeof(req));
            ((CXWnd*)this)->Show(false, false);
        }
        else if (m_pGroupCheckbox && pWnd == (CXWnd*)m_pGroupCheckbox) {
            WaypointRequest_Struct req;
            memset(&req, 0, sizeof(req));
            req.waypoint_id = 0;
            req.expedition_selected = false;
            req.group_selected = m_pGroupCheckbox->Checked != 0;
            req.autoconfirm_selected = m_pAutoAcceptCheckbox ? (m_pAutoAcceptCheckbox->Checked != 0) : false;
            
            SendEQMessage(0x1403, &req, sizeof(req));
        }
        else if (m_pAutoAcceptCheckbox && pWnd == (CXWnd*)m_pAutoAcceptCheckbox) {
            WaypointRequest_Struct req;
            memset(&req, 0, sizeof(req));
            req.waypoint_id = 0;
            req.expedition_selected = false;
            req.group_selected = m_pGroupCheckbox ? (m_pGroupCheckbox->Checked != 0) : false;
            req.autoconfirm_selected = m_pAutoAcceptCheckbox->Checked != 0;
            
            SendEQMessage(0x1403, &req, sizeof(req));
        }
    }
    return CSidlScreenWnd::WndNotification(pWnd, Message, data);
}

void WaypointsWnd::OnSetGameState(int state) {
    if (state != 5 && s_instance) {
        ((CXWnd*)s_instance)->Show(false, false);
    }
}
