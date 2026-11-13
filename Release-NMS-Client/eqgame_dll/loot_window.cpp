#include "loot_window.h"
#include "MQ2Globals.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern VOID SendEQMessage(DWORD PacketType, PVOID pData, DWORD Length);
extern void AddXMLFile(const char *filename);

static const unsigned int OP_NMS_LOOT_OFFER   = 0x140C;  // server -> client
static const unsigned int OP_NMS_LOOT_DECISION = 0x140D;  // client -> server

LootWnd* LootWnd::s_instance = nullptr;

LootWnd* LootWnd::GetInstance() {
    return s_instance;
}

LootWnd::LootWnd() : CCustomWnd("NMSLootWnd") {
    m_pPendingList   = (CListWnd*)GetChildItem("NMSLootPendingList");
    m_pRulesList     = (CListWnd*)GetChildItem("NMSLootRulesList");
    m_pBagBtn        = (CButtonWnd*)GetChildItem("NMSLootBagBtn");
    m_pBankBtn       = (CButtonWnd*)GetChildItem("NMSLootBankBtn");
    m_pSellBtn       = (CButtonWnd*)GetChildItem("NMSLootSellBtn");
    m_pTributeBtn    = (CButtonWnd*)GetChildItem("NMSLootTributeBtn");
    m_pVaultBtn      = (CButtonWnd*)GetChildItem("NMSLootVaultBtn");
    m_pDestroyBtn    = (CButtonWnd*)GetChildItem("NMSLootDestroyBtn");
    m_pPassBtn       = (CButtonWnd*)GetChildItem("NMSLootPassBtn");
    m_pBagAllBtn     = (CButtonWnd*)GetChildItem("NMSLootBagAllBtn");
    m_pBankAllBtn    = (CButtonWnd*)GetChildItem("NMSLootBankAllBtn");
    m_pSellNormalBtn = (CButtonWnd*)GetChildItem("NMSLootSellNormalBtn");
    m_pAlwaysCheck   = (CButtonWnd*)GetChildItem("NMSLootAlwaysCheck");
    m_pRuleKeepBtn   = (CButtonWnd*)GetChildItem("NMSLootRuleBagBtn");   // relabelled "Keep"
    m_pRuleBankBtn   = (CButtonWnd*)GetChildItem("NMSLootRuleBankBtn");
    m_pRuleRemoveBtn = (CButtonWnd*)GetChildItem("NMSLootRuleRemoveBtn");
    m_pDefAskCheck   = (CButtonWnd*)GetChildItem("NMSLootDefAskCheck");
    m_pDefKeepCheck  = (CButtonWnd*)GetChildItem("NMSLootDefBagCheck");   // relabelled "Keep"
    m_pDefBankCheck  = (CButtonWnd*)GetChildItem("NMSLootDefBankCheck");
    m_defaultAction  = 0;

    if (!m_pPendingList) WriteChatf("[Loot] Failed to find NMSLootPendingList!");
    if (!m_pBagBtn)      WriteChatf("[Loot] Failed to find NMSLootBagBtn!");
    if (!m_pPassBtn)     WriteChatf("[Loot] Failed to find NMSLootPassBtn! NMS_LootWnd.xml in your active skin folder is an old copy.");

    m_ready = false;
    LoadRules();
}

// Everything that touches the client window tree happens here, on the first real offer -
// never in the constructor. Hiding controls and hooking the notification vtable while the
// object is still being built is what walked a half-built child chain (eqgame 0x468340).
void LootWnd::EnsureReady() {
    if (m_ready) {
        return;
    }
    m_ready = true;

    // Controls kept in the shared XML but not used by this protocol: auto-sell has no wire
    // sell value (it would answer, be refused, and re-answer forever), so the sell rule and
    // the sell default stay hidden.
    HideUnsupportedControls();

    // Hook the WndNotification function into the vtable
    SetWndNotification(LootWnd);

    WriteChatf("[Loot] Loot window loaded (DLL built %s %s).", __DATE__, __TIME__);
}

LootWnd::~LootWnd() {
}

void LootWnd::HideUnsupportedControls() {
    static const char* hidden[] = {
        "NMSLootRuleSellBtn",
        "NMSLootDefSellCheck", "NMSLootDefSellLabel",
    };
    for (const char* id : hidden) {
        // (PCHAR) is deliberate. The plain call resolves to the client's own
        // GetChildItem(CXStr const&) because a const char* cannot bind to the char*
        // overload; that native walk is the code path nobody else in this DLL uses, and on
        // this window it faults (eqgame 0x468340) instead of returning null. The char*
        // overload uses MQ's RecurseAndFindName, which every other lookup already uses.
        CXWnd* ctl = ((CXWnd*)this)->GetChildItem((PCHAR)id);
        if (ctl) {
            ctl->Show(false, false);
        }
    }
}

void LootWnd::Initialize() {
    AddXMLFile("NMS_LootWnd.xml");
}

// /nmsloot: ask the server to resend this character's pending offers. The reply comes
// through OnIncomingPacket -> HandleOfferList, which is the only place that creates
// the window and fills the list. Do not construct/populate the window here: MacroQuest
// owns the UI teardown and a window created off the packet path is not MQ-safe.
void LootWnd::ShowWindow() {
    if (gGameState != GAMESTATE_INGAME) {
        WriteChatf("[Loot] Enter the world first.");
        return;
    }
    if (!pSidlMgr || !pSidlMgr->FindScreenPieceTemplate("NMSLootWnd")) {
        WriteChatf("[Loot] Window template 'NMSLootWnd' not found. Install NMS_LootWnd.xml in uifiles (then /loadskin).");
        return;
    }

    if (s_instance) {
        s_instance->SendDecision(0, 0, ACT_REFRESH, "");
        ((CXWnd*)s_instance)->Show(true, true);
        return;
    }

    Decision d;
    memset(&d, 0, sizeof(d));
    d.action = ACT_REFRESH;
    SendEQMessage(OP_NMS_LOOT_DECISION, &d, (DWORD)sizeof(d));
    WriteChatf("[Loot] Requested pending loot offers.");
}

VOID CmdNmsLoot(PSPAWNINFO, PCHAR) {
    LootWnd::ShowWindow();
}

void LootWnd::Shutdown() {
    if (s_instance) {
        ((CXWnd*)s_instance)->Show(false, false);
        delete s_instance;
        s_instance = nullptr;
    }
}

void LootWnd::OnIncomingPacket(uint16_t opcode, void* buf, size_t size) {
    if (opcode != OP_NMS_LOOT_OFFER || !buf || size < sizeof(OfferHeader)) {
        return;
    }
    if (gGameState != GAMESTATE_INGAME) {
        return;
    }

    if (!pSidlMgr->FindScreenPieceTemplate("NMSLootWnd")) {
        // Without the XML the offers would be unseen; the server delivers expired offers to
        // bags anyway, so nothing is lost - but say so once.
        static bool warned = false;
        if (!warned) {
            warned = true;
            WriteChatf("[Loot] Window template 'NMSLootWnd' not found. Install NMS_LootWnd.xml in uifiles (then /loadskin) to use the loot window.");
        }
        return;
    }

    if (!s_instance) {
        s_instance = new LootWnd();
    }
    if (!s_instance) {
        return;
    }

    s_instance->HandleOfferList(buf, size);
}

// OP_NmsLootOffer: header, then count x entry (the pending list is replaced wholesale)
void LootWnd::HandleOfferList(const void* buf, size_t size) {
    const OfferHeader* header = (const OfferHeader*)buf;
    size_t expect = sizeof(OfferHeader) + (size_t)header->count * sizeof(OfferEntry);
    if (size < expect) {
        return; // truncated packet: keep whatever was shown before
    }

    EnsureReady(); // window-tree work is deferred out of the constructor

    char title[65];
    title[64] = '\0';
    strncpy(title, header->title, 64);
    m_title = title;
    m_expireSeconds = header->expire_seconds;

    m_pending.clear();
    const OfferEntry* entries = (const OfferEntry*)((const uint8_t*)buf + sizeof(OfferHeader));
    for (uint32_t i = 0; i < header->count; ++i) {
        PendingItem p;
        p.item_id   = entries[i].item_id;
        p.charges   = entries[i].charges;
        p.offer_id  = entries[i].offer_id;
        char name[65];
        name[64] = '\0';
        strncpy(name, entries[i].name, 64);
        p.name = name;
        char passer[65];
        passer[64] = '\0';
        strncpy(passer, entries[i].name2, 64);
        p.passed_in = passer[0] != '\0';
        p.passer = p.passed_in ? passer : m_title;
        if (p.offer_id) {
            m_pending.push_back(p);
        }
    }

    AutoAnswer();
    Populate();

    if (!m_pending.empty()) {
        ((CXWnd*)this)->Show(true, true);
    }
}

// ---- client-side rules ----

std::string LootWnd::RulesIniPath() const {
    char path[MAX_PATH] = { 0 };
    GetModuleFileNameA(NULL, path, MAX_PATH); // eqgame.exe, whose folder holds the ini
    char* slash = strrchr(path, '\\');
    if (slash) {
        slash[1] = '\0';
    }
    std::string out = path;
    out += pCharSpawn ? ((PSPAWNINFO)pCharSpawn)->Name : "character";
    out += "_itemrules.ini";
    return out;
}

// One section per rule type, "item_id=Item Name" per line - the hailstone itemrules.ini layout.
void LootWnd::LoadRules() {
    m_rules.clear();
    m_iniPath = RulesIniPath();
    if (m_iniPath.empty() || GetFileAttributesA(m_iniPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
        return;
    }
    const char* sections[] = { "AlwaysKeep", "AlwaysBank" };
    const uint8_t actions[] = { ACT_KEEP, ACT_BANK };
    for (int s = 0; s < 2; ++s) {
        char names[32768] = { 0 };
        DWORD read = GetPrivateProfileStringA(sections[s], NULL, "", names, sizeof(names), m_iniPath.c_str());
        for (const char* k = names; k && *k && read; k += strlen(k) + 1) {
            uint32_t id = (uint32_t)strtoul(k, NULL, 10);
            if (!id) {
                continue;
            }
            char ininame[32];
            sprintf(ininame, "%u", id);
            char valname[256] = { 0 };
            GetPrivateProfileStringA(sections[s], ininame, "", valname, sizeof(valname), m_iniPath.c_str());
            RuleItem r;
            r.item_id = id;
            r.action = actions[s];
            r.name = valname;
            for (size_t i = 0; i < m_rules.size(); ++i) {
                if (m_rules[i].item_id == id) { // id in two sections takes the last
                    m_rules[i] = r;
                    r.item_id = 0;
                    break;
                }
            }
            if (r.item_id) {
                m_rules.push_back(r);
            }
        }
    }
}

void LootWnd::SaveRules() const {
    if (m_iniPath.empty()) {
        return;
    }
    WritePrivateProfileStringA(NULL, NULL, NULL, m_iniPath.c_str()); // clear all sections
    for (const RuleItem& r : m_rules) {
        const char* section = (r.action == ACT_BANK) ? "AlwaysBank" : "AlwaysKeep";
        char ininame[32];
        sprintf(ininame, "%u", r.item_id);
        WritePrivateProfileStringA(section, ininame, r.name.c_str(), m_iniPath.c_str());
    }
}

const LootWnd::RuleItem* LootWnd::FindRule(uint32_t item_id) const {
    for (const RuleItem& r : m_rules) {
        if (r.item_id == item_id) {
            return &r;
        }
    }
    return nullptr;
}

void LootWnd::SetRule(uint32_t item_id, const std::string& name, uint8_t action) {
    for (size_t i = 0; i < m_rules.size(); ++i) {
        if (m_rules[i].item_id == item_id) {
            if (action) {
                m_rules[i].action = action;
                m_rules[i].name = name;
            } else {
                m_rules.erase(m_rules.begin() + i);
            }
            SaveRules();
            PopulateRules();
            return;
        }
    }
    if (action) {
        RuleItem r;
        r.item_id = item_id;
        r.action = action;
        r.name = name;
        m_rules.push_back(r);
        SaveRules();
        PopulateRules();
    }
}

// Answer every pending row a rule covers, then rows matching the no-rule default. Ask (0)
// leaves the row for the player. Keep/Bank are always appliable - the server re-saves an
// offer it cannot deliver and the next list retries - so no auto-answer here can loop badly.
void LootWnd::AutoAnswer() {
    if (m_pending.empty()) {
        return;
    }
    std::vector<PendingItem> left;
    for (const PendingItem& p : m_pending) {
        uint8_t action = 0;
        if (const RuleItem* r = FindRule(p.item_id)) {
            action = r->action;
        } else {
            action = (uint8_t)m_defaultAction;
        }
        if (action) {
            SendDecision(p.offer_id, p.item_id, action, "");
        } else {
            left.push_back(p);
        }
    }
    m_pending.swap(left);
}

void LootWnd::MaybeSaveRule(const PendingItem& p, uint8_t action) {
    if (!m_pAlwaysCheck || m_pAlwaysCheck->Checked == 0) {
        return;
    }
    if (action == ACT_KEEP || action == ACT_BANK) {
        SetRule(p.item_id, p.name, action);
        WriteChatf("[Loot] Always %s %s.", action == ACT_BANK ? "bank" : "keep", p.name.c_str());
    }
}

// ---- list helpers ----

uint32_t LootWnd::SelectedData(CListWnd* list) {
    if (!list) return 0;
    int sel = list->GetCurSel();
    if (sel == -1) return 0;
    return (uint32_t)list->GetItemData(sel);
}

void LootWnd::SelectById(CListWnd* list, uint32_t id) {
    if (!list || !id) return;
    for (int i = 0; i < list->Items; i++) {
        if ((uint32_t)list->GetItemData(i) == id) {
            list->SetCurSel(i);
            return;
        }
    }
}

void LootWnd::Populate() {
    if (m_pPendingList) {
        uint32_t keep = SelectedData(m_pPendingList);
        m_pPendingList->DeleteAll();

        for (size_t i = 0; i < m_pending.size(); i++) {
            const PendingItem& p = m_pending[i];
            // rows covered by a saved rule are tinted until the answer lands
            uint32_t color = FindRule(p.item_id) ? 0xFF66FF66 : 0xFFFFFFFF;

            int index = m_pPendingList->AddString(p.name.c_str(), color, (uint32_t)p.offer_id, 0);

            CXStr szName(p.name.c_str());
            m_pPendingList->SetItemText(index, 1, &szName);

            char qty[32];
            sprintf(qty, "%d", p.charges > 0 ? p.charges : 1);
            CXStr szQty(qty);
            m_pPendingList->SetItemText(index, 2, &szQty);

            // Column 3 is headed "Expires in" (shared countdown from the packet header; the
            // server delivers expired offers to bags, so it never just vanishes)
            char exp[32];
            sprintf(exp, "%us", m_expireSeconds);
            CXStr szExp(exp);
            m_pPendingList->SetItemText(index, 3, &szExp);

            m_pPendingList->SetItemData(index, (uint32_t)p.offer_id);
        }
        SelectById(m_pPendingList, keep);
    }
    PopulateRules();
    SyncDefaultChecks();
}

void LootWnd::PopulateRules() {
    if (m_pRulesList) {
        uint32_t keep = SelectedData(m_pRulesList);
        m_pRulesList->DeleteAll();
        for (size_t i = 0; i < m_rules.size(); i++) {
            const RuleItem& r = m_rules[i];
            int index = m_pRulesList->AddString(r.name.c_str(), 0xFFFFFFFF, (uint32_t)r.item_id, 0);
            CXStr szName(r.name.c_str());
            m_pRulesList->SetItemText(index, 1, &szName);
            CXStr szAction(r.action == ACT_BANK ? "Bank" : "Keep");
            m_pRulesList->SetItemText(index, 2, &szAction);
            m_pRulesList->SetItemData(index, (uint32_t)r.item_id);
        }
        SelectById(m_pRulesList, keep);
    }
}

// Write Checked directly (SetCheck does not take; see WaypointsWnd::HandleWaypointList).
void LootWnd::SyncDefaultChecks() {
    if (m_pDefAskCheck)  m_pDefAskCheck->Checked  = (m_defaultAction == 0) ? 1 : 0;
    if (m_pDefKeepCheck) m_pDefKeepCheck->Checked = (m_defaultAction == ACT_KEEP) ? 1 : 0;
    if (m_pDefBankCheck) m_pDefBankCheck->Checked = (m_defaultAction == ACT_BANK) ? 1 : 0;
}

void LootWnd::SendDecision(uint32_t offer_id, uint32_t item_id, uint8_t action, const char* pass_to) {
    Decision d;
    memset(&d, 0, sizeof(d));
    d.offer_id = offer_id;
    d.item_id  = item_id;
    d.action   = action;
    if (pass_to && pass_to[0]) {
        strncpy(d.name, pass_to, sizeof(d.name) - 1);
    }
    SendEQMessage(OP_NMS_LOOT_DECISION, &d, (DWORD)sizeof(d));
}

// The pending row for the currently selected offer, or null
const LootWnd::PendingItem* LootWnd::FindPending(uint32_t offer_id) const {
    for (const PendingItem& p : m_pending) {
        if (p.offer_id == offer_id) {
            return &p;
        }
    }
    return nullptr;
}

void LootWnd::DoAction(uint8_t action) {
    uint32_t offer_id = SelectedData(m_pPendingList);
    const PendingItem* chosen = FindPending(offer_id);
    if (!chosen) {
        WriteChatf("[Loot] Click an item in the waiting list first.");
        return;
    }

    MaybeSaveRule(*chosen, action);
    SendDecision(chosen->offer_id, chosen->item_id, action, "");
    // Optimistic removal; a re-sent list (the action could not be carried out) restores the row
    for (size_t i = 0; i < m_pending.size(); ++i) {
        if (m_pending[i].offer_id == offer_id) {
            m_pending.erase(m_pending.begin() + i);
            break;
        }
    }
    Populate();
    if (m_pending.empty()) {
        ((CXWnd*)this)->Show(false, true);
    }
}

void LootWnd::DoBulkAction(uint8_t action) {
    if (m_pending.empty()) {
        WriteChatf("[Loot] Nothing waiting.");
        return;
    }
    // One decision per offer; Sell on a no-value item is refused by the server (its offer stays)
    for (const PendingItem& p : m_pending) {
        SendDecision(p.offer_id, p.item_id, action, "");
    }
    m_pending.clear();
    Populate();
    ((CXWnd*)this)->Show(false, true);
}

// Pass to the current target; a row that arrived via Pass is returned to its passer instead
// (action 9 needs no name - the server knows where it came from).
void LootWnd::DoPass() {
    uint32_t offer_id = SelectedData(m_pPendingList);
    const PendingItem* chosen = FindPending(offer_id);
    if (!chosen) {
        WriteChatf("[Loot] Click an item in the waiting list first.");
        return;
    }

    if (chosen->passed_in) {
        SendDecision(chosen->offer_id, chosen->item_id, ACT_RETURN, "");
        WriteChatf("[Loot] Returning %s to %s.", chosen->name.c_str(), chosen->passer.c_str());
    } else {
        PSPAWNINFO target = (PSPAWNINFO)pTarget;
        if (!target || !target->Name[0]) {
            WriteChatf("[Loot] Target the player you want to pass %s to.", chosen->name.c_str());
            return;
        }
        SendDecision(chosen->offer_id, chosen->item_id, ACT_PASS, target->Name);
        WriteChatf("[Loot] Passing %s to %s.", chosen->name.c_str(), target->Name);
    }
    for (size_t i = 0; i < m_pending.size(); ++i) {
        if (m_pending[i].offer_id == offer_id) {
            m_pending.erase(m_pending.begin() + i);
            break;
        }
    }
    Populate();
    if (m_pending.empty()) {
        ((CXWnd*)this)->Show(false, true);
    }
}

// Change or remove the rule selected in the rules list
void LootWnd::DoRuleAction(uint8_t action) {
    uint32_t item_id = SelectedData(m_pRulesList);
    if (!item_id) {
        WriteChatf("[Loot] Click a saved rule first.");
        return;
    }
    const RuleItem* r = FindRule(item_id);
    SetRule(item_id, r ? r->name : "", action); // action 0 = remove
}

int LootWnd::WndNotification(CXWnd* pWnd, unsigned int Message, void* data) {
    if (Message == XWM_LCLICK) {
#define LOOT_IS(ptr) ((ptr) && pWnd == (CXWnd*)(ptr))
        if      (LOOT_IS(m_pBagBtn))        DoAction(ACT_KEEP);
        else if (LOOT_IS(m_pBankBtn))       DoAction(ACT_BANK);
        else if (LOOT_IS(m_pSellBtn))       DoAction(ACT_SELL);
        else if (LOOT_IS(m_pTributeBtn))    DoAction(ACT_TRIBUTE);
        else if (LOOT_IS(m_pVaultBtn))      DoAction(ACT_VAULT);
        else if (LOOT_IS(m_pDestroyBtn))    DoAction(ACT_DESTROY);
        else if (LOOT_IS(m_pPassBtn))       DoPass();
        else if (LOOT_IS(m_pBagAllBtn))     DoBulkAction(ACT_KEEP);
        else if (LOOT_IS(m_pBankAllBtn))    DoBulkAction(ACT_BANK);
        else if (LOOT_IS(m_pSellNormalBtn)) DoBulkAction(ACT_SELL);
        else if (LOOT_IS(m_pRuleKeepBtn))   DoRuleAction(ACT_KEEP);
        else if (LOOT_IS(m_pRuleBankBtn))   DoRuleAction(ACT_BANK);
        else if (LOOT_IS(m_pRuleRemoveBtn)) DoRuleAction(0);
        else if (LOOT_IS(m_pDefAskCheck))  { m_defaultAction = 0;        SyncDefaultChecks(); }
        else if (LOOT_IS(m_pDefKeepCheck)) { m_defaultAction = ACT_KEEP; SyncDefaultChecks(); }
        else if (LOOT_IS(m_pDefBankCheck)) { m_defaultAction = ACT_BANK; SyncDefaultChecks(); }
#undef LOOT_IS
    }
    return CSidlScreenWnd::WndNotification(pWnd, Message, data);
}
