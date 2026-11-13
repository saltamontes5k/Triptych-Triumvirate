#pragma once
#include "MQ2Main.h"
#include <vector>
#include <string>
#include <cstdint>

// NMS personal loot window (the server's /nmsloot offers).
//
// Adapted from the InstancedLoot Loot Manager window (same SIDL scaffolding: NMS_LootWnd.xml
// supplies the controls, this class finds them by ScreenID, fills the pending list and reacts
// to clicks), but speaking the server's binary offer protocol instead of text commands:
//
//   server -> client  0x140C  OP_NmsLootOffer    86B header + count x 150B entries (count 0 = none)
//   client -> server  0x140D  OP_NmsLootDecision 75B: offer id, item id, action, pass-to name
//
// Actions (module numbering, mirrored server-side): 1 Keep, 2 Sell, 3 Tribute, 4 Bank,
// 5 Vault, 6 Destroy, 7 Pass (name), 9 Return. A decision removes its row locally; the server
// re-sends the list when the action could not be carried out, which restores the row.
//
// Client-side rules ("<charname>_itemrules.ini" next to eqgame.exe, hailstone's convention):
// Always Keep / Always Bank per item id, answered automatically when the list arrives, plus a
// default for items with no rule (Ask / Keep / Bank). There are deliberately no sell rules and
// no auto-sell default: the 150-byte offer entry carries no sell value, so an auto-sell of a
// zero-value item would be refused, re-saved under a new offer id and answered again forever.
VOID CmdNmsLoot(PSPAWNINFO pChar, PCHAR szLine);

class LootWnd : public CCustomWnd {
public:
    LootWnd();
    ~LootWnd();

    int WndNotification(CXWnd* pWnd, unsigned int Message, void* data);

    static void Initialize();
    static void Shutdown();
    static void OnIncomingPacket(uint16_t opcode, void* buf, size_t size);
    static LootWnd* GetInstance();
    static void ShowWindow();   // /nmsloot: ask the server for a refresh, then show the list

    void HandleOfferList(const void* buf, size_t size);

private:
    static LootWnd* s_instance;

    // Wire layouts - byte-identical to the server's common/eq_packet_structs.h (86/150/75).
#pragma pack(push, 1)
    struct OfferHeader {
        uint16_t unknown_u16;
        char     title[64];
        uint32_t corpse_id;
        uint32_t expire_seconds;
        uint32_t unknown_a;
        uint32_t unknown_b;
        uint32_t count;
    };
    struct OfferEntry {
        uint32_t item_id;
        uint32_t icon;
        int32_t  charges;
        uint32_t offer_id;
        uint8_t  bonus;
        uint8_t  unknown_17[5];
        char     name[64];
        char     name2[64];
    };
    struct Decision {
        uint16_t unknown_u16;
        uint32_t offer_id;
        uint32_t item_id;
        uint8_t  action;
        char     name[64];
    };
#pragma pack(pop)
    static_assert(sizeof(OfferHeader) == 86, "OfferHeader must match the server's NmsLootOfferHeader_Struct");
    static_assert(sizeof(OfferEntry) == 150, "OfferEntry must match the server's NmsLootOfferEntry_Struct");
    static_assert(sizeof(Decision) == 75, "Decision must match the server's NmsLootDecision_Struct");

    // Module action numbers (server mirrors them in NmsLootAction)
    enum {
        ACT_KEEP    = 1,
        ACT_SELL    = 2,
        ACT_TRIBUTE = 3,
        ACT_BANK    = 4,
        ACT_VAULT   = 5,
        ACT_DESTROY = 6,
        ACT_PASS    = 7,
        ACT_REFRESH = 8,   // /nmsloot: resend the pending list, no decision
        ACT_RETURN  = 9,
    };

    struct PendingItem {
        uint32_t    offer_id;
        uint32_t    item_id;
        int32_t     charges;
        std::string name;
        std::string passer;    // shown: who passed it, else the corpse it came from
        bool        passed_in; // raw name2 was set: this row arrived via Pass, so Pass returns it
    };

    // A saved rule. Actions restricted to Keep (1) and Bank (4): both are always appliable
    // (failure re-saves the offer for a benign retry); Sell is excluded for lack of a wire
    // sell value (see class comment).
    struct RuleItem {
        uint32_t    item_id;
        uint8_t     action; // ACT_KEEP or ACT_BANK
        std::string name;
    };

    void EnsureReady();                                  // one-time hide/notify, first offer only
    const PendingItem* FindPending(uint32_t offer_id) const;
    void Populate();
    void PopulateRules();
    void SendDecision(uint32_t offer_id, uint32_t item_id, uint8_t action, const char* pass_to);
    void DoAction(uint8_t action);                       // module action on the selected pending row
    void DoBulkAction(uint8_t action);                   // the same action on every pending row
    void DoPass();                                       // pass to current target, or return a passed row
    void DoRuleAction(uint8_t action);                   // change / remove the selected saved rule
    void MaybeSaveRule(const PendingItem& p, uint8_t action); // with Always ticked
    void AutoAnswer();                                   // rules + default for every pending row
    void LoadRules();
    void SaveRules() const;
    const RuleItem* FindRule(uint32_t item_id) const;
    void SetRule(uint32_t item_id, const std::string& name, uint8_t action);
    void SyncDefaultChecks();
    static uint32_t SelectedData(CListWnd* list);
    static void SelectById(CListWnd* list, uint32_t id);
    void HideUnsupportedControls();
    std::string RulesIniPath() const;

    CListWnd*   m_pPendingList;
    CListWnd*   m_pRulesList;
    CButtonWnd* m_pBagBtn;        // "Keep"
    CButtonWnd* m_pBankBtn;
    CButtonWnd* m_pSellBtn;
    CButtonWnd* m_pTributeBtn;
    CButtonWnd* m_pVaultBtn;
    CButtonWnd* m_pDestroyBtn;
    CButtonWnd* m_pPassBtn;       // was the Inspect button in the shared XML
    CButtonWnd* m_pBagAllBtn;     // "Keep All"
    CButtonWnd* m_pBankAllBtn;
    CButtonWnd* m_pSellNormalBtn; // "Sell All"
    CButtonWnd* m_pAlwaysCheck;
    CButtonWnd* m_pRuleKeepBtn;   // was RuleBagBtn
    CButtonWnd* m_pRuleBankBtn;
    CButtonWnd* m_pRuleRemoveBtn;
    CButtonWnd* m_pDefAskCheck;
    CButtonWnd* m_pDefKeepCheck;  // was DefBagCheck
    CButtonWnd* m_pDefBankCheck;

    std::vector<PendingItem> m_pending;
    std::vector<RuleItem>    m_rules;
    std::string              m_title;        // the corpse the offers came from
    std::string              m_iniPath;
    uint32_t                 m_expireSeconds;
    int                      m_defaultAction; // 0 ask, ACT_KEEP, ACT_BANK
    bool                     m_ready;         // EnsureReady() has run
};
