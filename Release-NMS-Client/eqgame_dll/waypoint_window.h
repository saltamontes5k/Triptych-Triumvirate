#pragma once
#include "MQ2Main.h"
#include <vector>
#include <map>
#include <set>
#include <string>

class WaypointsWnd : public CCustomWnd {
public:
    WaypointsWnd();
    ~WaypointsWnd();

    int WndNotification(CXWnd* pWnd, unsigned int Message, void* data);
    
    static void Initialize();
    static void Shutdown();
    static void OnIncomingPacket(uint16_t opcode, void* buf, size_t size);
    static bool OnOutgoingPacket(uint16_t opcode, void* buf, size_t size);
    static void OnPulse();
    static void OnSetGameState(int state);
    static WaypointsWnd* GetInstance();

    void HandleWaypointList(void* buf, size_t size);
    void PopulateContinents();
    void PopulateWaypoints(int category_id);

private:
    static WaypointsWnd* s_instance;

    CListWnd* m_pContinentsList;
    CListWnd* m_pWaypointsList;
    CButtonWnd* m_pTravelButton;
    CButtonWnd* m_pExpeditionButton;
    CButtonWnd* m_pGroupCheckbox;
    CButtonWnd* m_pAutoAcceptCheckbox;
    CXWnd* m_pPortGroupLabel;
    CXWnd* m_pAutoAcceptLabel;

    struct WaypointData {
        int32_t id;
        int32_t category_id;
        bool enabled;
        char name[64];
    };

    std::vector<WaypointData> m_waypoints;
    std::map<int32_t, std::string> m_categories;
};
