// DPS ADV CREATED BY WARNEN 2008-2009
// MQ2DPSAdv.cpp

using namespace std;
#include <vector>
#include <sstream>
#include <list>
#include "MQ2Main.h"

int ColorTest[17];
PSPAWNINFO   LastMob;
PSPAWNINFO   CurTarMob;
PSPAWNINFO   CurListMob;
PSPAWNINFO   CurMaxMob;
PSPAWNINFO   CurTarget;
time_t      Intervals;
int         CListType;
int         MaxDmgLast;
int         MeColor;
int         MeTopColor;
int         NormalColor;
int         NPCColor;
int         TotalColor;
int         EntHover;
int         EntHighlight;
int         FightNormal;
int         FightHover;
int         FightHighlight;
int         FightActive;
int         FightInActive;
int         FightDead;
bool      Saved;
bool      WarnedYHO, WarnedOHO;
bool      Debug;
bool      Active;
bool      Zoning;
bool      WrongUI;

bool      ShowMeTop;
bool      ShowMeMin;
int         ShowMeMinNum;
bool      ClearAfterCombat;
bool      LiveUpdate;
int         ShowTotal;
int         EntTO;
CDPSAdvWnd *DPSWnd = 0;

#define DPSVERSION "1.2.06"
//#define DPSDEV

extern std::map<uint32_t, EdgeDPSEntry> DamageEntries;


std::string commify(const std::string &number)
{
	std::string temp_string;

	auto string_length = static_cast<int>(number.length());

	int i = 0;
	for (i = string_length - 3; i >= 0; i -= 3) {
		if (i > 0) {
			temp_string = "," + number.substr(static_cast<unsigned long>(i), 3) + temp_string;
		}
		else {
			temp_string = number.substr(static_cast<unsigned long>(i), 3) + temp_string;
		}
	}

	if (i < 0) {
		temp_string = number.substr(0, static_cast<unsigned long>(3 + i)) + temp_string;
	}

	return temp_string;
}

// ############################### CDPSAdvWnd START ############################################
bool bCleaned = false;
void ZoneProcess() {
	LastMob = 0;
	CurTarget = 0;
	CurTarMob = 0;
	CurListMob = 0;
	CurMaxMob = 0;
	DPSMob *pMob = 0;
	DPSMob::DPSEntry *pEnt = 0;

}

CDPSAdvWnd::CDPSAdvWnd() :CCustomWnd("DPSAdvWnd") {
	int CheckUI = false;
	if (!(Tabs = (CTabWnd*)GetChildItem("DPS_Tabs"))) CheckUI = true;
	if (!(LTopList = (CListWnd*)GetChildItem("DPS_TopList"))) CheckUI = true;
	if (!(CMobList = (CComboWnd*)GetChildItem("DPS_MobList"))) CheckUI = true;
	if (!(CShowMeTop = (CCheckBoxWnd*)GetChildItem("DPS_ShowMeTopBox"))) CheckUI = true;
	if (!(CShowMeMin = (CCheckBoxWnd*)GetChildItem("DPS_ShowMeMinBox"))) CheckUI = true;
	if (!(TShowMeMin = (CTextEntryWnd*)GetChildItem("DPS_ShowMeMinInput"))) CheckUI = true;
	if (!(CClearAfterCombatBox = (CCheckBoxWnd*)GetChildItem("DPS_ClearAfterCombatBox"))) CheckUI = true;
	if (!(CLiveUpdate = (CCheckBoxWnd*)GetChildItem("DPS_LiveUpdateBox"))) CheckUI = true;
	if (!(TEntTO = (CTextEntryWnd*)GetChildItem("DPS_EntTOInput"))) CheckUI = true;
	if (!(CShowTotal = (CComboWnd*)GetChildItem("DPS_ShowTotal"))) CheckUI = true;
	//if (!(LFightList = (CListWnd*)GetChildItem("DPS_FightList"))) CheckUI = true;
	this->BGColor.ARGB = 0xFF000000;
	Tabs->BGColor.ARGB = 0xFF000000;
	LTopList->BGColor.ARGB = 0xFF000000;
	TEntTO->BGColor.ARGB = 0xFF000000;
	CShowTotal->BGColor.ARGB = 0xFF000000;
	if (CheckUI) {
		WriteChatf("\ar[DPSAdv] Incorrect UI File in use. Please update to the latest client files.");
		WrongUI = true;
		return;
	}
	else WrongUI = false;
	LoadLoc();
	SetWndNotification(CDPSAdvWnd);
	//LTopList->SetColors(0xFFFFFFFF, 0xFFCC3333, 0xFF666666);
	//LFightList->SetColors(0xFFFFFFFF, 0xFFCC3333, 0xFF666666);
	CMobList->SetColors(0xFFCC3333, 0xFF666666, 0xFF000000);
	Tabs->UpdatePage();
	DrawCombo();
	//LFightList->AddString(&CXStr("1"), 0, 0, 0);
	//LFightList->AddString(&CXStr("2"), 0, 0, 0);
	//LFightList->AddString(&CXStr("3"), 0, 0, 0);
	//LFightList->ExtendSel(1);
	//LFightList->ExtendSel(2);
}

CDPSAdvWnd::~CDPSAdvWnd() {}

void CDPSAdvWnd::DrawCombo() {
	int CurSel = CMobList->GetCurChoice();
	CMobList->DeleteAll();
	CHAR szTemp[MAX_STRING] = { 0 };
	//sprintf_s(szTemp, "<Target> %s", CurListMob ? CurListMob->Name : "None");
	sprintf_s(szTemp, "<Target> %s", CListType == CLISTTARGET && CurListMob ? CurListMob->Name : "None");
	CMobList->InsertChoice(szTemp);
	sprintf_s(szTemp, "<MaxDmg> %s", CListType == CLISTMAXDMG && CurMaxMob ? CurListMob->Name : "None");
	CMobList->InsertChoice(szTemp);
	int i = 0, ListSize = 0;
	for (auto mob : DamageEntries) {

		auto entrySpawn = mob.second.SpawnID > 0 ? (PSPAWNINFO)GetSpawnByID(mob.second.SpawnID) : nullptr;

		if (entrySpawn && entrySpawn->Type == 1) {
			ListSize++;
			sprintf_s(szTemp, "(%i) %s", ListSize, entrySpawn->Name);
			CMobList->InsertChoice(szTemp);
		}
	}

	if (ListSize < 6) CMobList->InsertChoice("");

	if (CListType == CLISTTARGET) CMobList->SetChoice(0);
	else if (CListType == CLISTMAXDMG) CMobList->SetChoice(1);
	else CMobList->SetChoice(CurSel >= 0 ? CurSel : 0);
}

void CDPSAdvWnd::SetTotal(int LineNum, PSPAWNINFO Mob) {
	CHAR szTemp[MAX_STRING] = { 0 };

	if (!Mob)
		return;

	EdgeDPSEntry Entry = GetEdgeDPSEntryByID(Mob->SpawnID, false);


	if (Entry.SpawnID)
	{
		SetLineColors(LineNum, Entry, true, false, false);
		LTopList->SetItemText(LineNum, 0, &CXStr("-"));
		LTopList->SetItemText(LineNum, 1, &CXStr("Total"));
		sprintf_s(szTemp, "%I64d", Entry.TotalIncomingDamage);
		LTopList->SetItemText(LineNum, 2, &CXStr(commify(szTemp).c_str()));

		std::chrono::duration<double> elapsed_seconds = Entry.LastUpdateTimestamp - Entry.BeginningTimestamp;



		auto dpsTOTAL = 0;
		auto dpsAVRGE = 0;

		int64_t damages = Entry.TotalIncomingDamage;
		DOUBLE estimate = damages / elapsed_seconds.count();
		dpsTOTAL++;
		DOUBLE evaluate = (estimate - dpsAVRGE) / dpsTOTAL + dpsAVRGE; dpsAVRGE = evaluate;
		if (elapsed_seconds.count() == 0.0)
		{
			evaluate = 0.f;
		}

		std::stringstream outEstimate;
		outEstimate << (int64_t)estimate;
		LTopList->SetItemText(LineNum, 3, &CXStr(commify(outEstimate.str()).c_str()));


		sprintf_s(szTemp, "%I64d", Entry.TotalOutgoingDamage);
		LTopList->SetItemText(LineNum, 4, &CXStr(commify(szTemp).c_str()));

		dpsTOTAL = 0;
		dpsAVRGE = 0;

		damages = Entry.TotalOutgoingDamage;
		estimate = damages / elapsed_seconds.count();
		dpsTOTAL++;
		evaluate = (estimate - dpsAVRGE) / dpsTOTAL + dpsAVRGE; dpsAVRGE = evaluate;
		if (elapsed_seconds.count() == 0.0)
		{
			evaluate = 0.f;
		}
		std::stringstream inEstimate;
		inEstimate << (int64_t)estimate;
		LTopList->SetItemText(LineNum, 5, &CXStr(inEstimate.str().c_str()));
	}
}

void CDPSAdvWnd::DrawList() {
	int ScrollPos = LTopList->VScrollPos;
	int CurSel = LTopList->GetCurSel();
	CHAR szTemp[MAX_STRING] = { 0 };
	LTopList->DeleteAll();
	int i = 0, LineNum = 0, RankAdj = 0, ShowMeLineNum = 0;
	bool FoundMe = false, ThisMe = false;
	if (ShowTotal == TOTALABOVE) {
		LineNum = LTopList->AddString(CXStr(" "), 0, 0, 0);
		SetTotal(LineNum, CurListMob);
		RankAdj++;
	}
	if (ShowMeTop) {
		ShowMeLineNum = LTopList->AddString(CXStr(" "), 0, 0, 0);
		SetLineColors(ShowMeLineNum, EdgeDPSEntry(), false, true, false);
		RankAdj++;
	}
	if (ShowTotal == TOTALSECOND) {
		LineNum = LTopList->AddString(CXStr(" "), 0, 0, 0);
		SetTotal(LineNum, CurListMob);
		RankAdj++;
	}

	for (auto entry : DamageEntries) {
		auto spawnEntry = (PSPAWNINFO)GetSpawnByID(entry.first);
		if (ShowMeTop && spawnEntry && !strcmp(spawnEntry->Name, ((PSPAWNINFO)pCharSpawn)->DisplayedName)) {
			if (!ShowMeMin || (LineNum - RankAdj + 1) > ShowMeMinNum) FoundMe = true;
			ThisMe = true;
		}
		else ThisMe = false;
		LineNum = LTopList->AddString(CXStr(" "), 0, 0, 0);
		SetLineColors(LineNum, entry.second);
		sprintf_s(szTemp, "%i", LineNum - RankAdj + 1);
		LTopList->SetItemText(LineNum, 0, &CXStr(szTemp));
		if (ThisMe) LTopList->SetItemText(ShowMeLineNum, 0, &CXStr(szTemp));
		sprintf_s(szTemp, "%s%s", spawnEntry ? spawnEntry->Name : " ", spawnEntry && spawnEntry->PetID > 0 ? "*" : " ");
		LTopList->SetItemText(LineNum, 1, &CXStr(szTemp));
		if (ThisMe) LTopList->SetItemText(ShowMeLineNum, 1, &CXStr(szTemp));
		sprintf_s(szTemp, "%I64d", entry.second.TotalIncomingDamage);
		LTopList->SetItemText(LineNum, 2, &CXStr(commify(szTemp).c_str()));
		if (ThisMe) LTopList->SetItemText(ShowMeLineNum, 2, &CXStr(commify(szTemp).c_str()));

		std::chrono::duration<double> elapsed_seconds = entry.second.LastUpdateTimestamp - entry.second.BeginningTimestamp;

		auto dpsTOTAL = 0;
		auto dpsAVRGE = 0;

		int64_t damages = entry.second.TotalIncomingDamage;
		DOUBLE estimate = damages / elapsed_seconds.count();
		dpsTOTAL++;
		DOUBLE evaluate = (estimate - dpsAVRGE) / dpsTOTAL + dpsAVRGE; dpsAVRGE = evaluate;
		if (elapsed_seconds.count() == 0.0)
		{
			evaluate = 0.f;
		}
		std::stringstream outEstimate;
		outEstimate << (int64_t)estimate;
		LTopList->SetItemText(LineNum, 3, &CXStr(commify(outEstimate.str()).c_str()));
		if (ThisMe) LTopList->SetItemText(ShowMeLineNum, 3, &CXStr(commify(outEstimate.str()).c_str()));

		sprintf_s(szTemp, "%I64d", entry.second.TotalOutgoingDamage);
		LTopList->SetItemText(LineNum, 4, &CXStr(commify(std::string(szTemp)).c_str()));
		
		dpsTOTAL = 0;
		dpsAVRGE = 0;

		damages = entry.second.TotalOutgoingDamage;
		estimate = damages / elapsed_seconds.count();
		dpsTOTAL++;
		evaluate = (estimate - dpsAVRGE) / dpsTOTAL + dpsAVRGE; dpsAVRGE = evaluate;
		if (elapsed_seconds.count() == 0.0)
		{
			evaluate = 0.f;
		}
		std::stringstream inEstimate;
		inEstimate << (int64_t)estimate;

		LTopList->SetItemText(LineNum, 5, &CXStr(commify(inEstimate.str()).c_str()));
		if (ThisMe) LTopList->SetItemText(ShowMeLineNum, 5, &CXStr(commify(inEstimate.str()).c_str()));

	}
	if (ShowTotal == TOTALBOTTOM) {
		LineNum = LTopList->AddString(CXStr(" "), 0, 0, 0);
		SetTotal(LineNum, CurListMob);
	}
	if (ShowMeTop && !FoundMe) LTopList->RemoveLine(ShowMeLineNum);
	LTopList->VScrollPos = ScrollPos;
	LTopList->CalculateFirstVisibleLine();
	LTopList->SetCurSel(CurSel);
}

void CDPSAdvWnd::SetLineColors(int LineNum, EdgeDPSEntry ent, bool Total, bool MeTop, bool UseEnt) {
	
	auto entrySpawn = ent.SpawnID > 0 && UseEnt ? (PSPAWNINFO)GetSpawnByID(ent.SpawnID) : nullptr;
	
	if (MeTop) {
		LTopList->SetItemColor(LineNum, 0, MeTopColor);
		LTopList->SetItemColor(LineNum, 1, MeTopColor);
		LTopList->SetItemColor(LineNum, 2, MeTopColor);
		LTopList->SetItemColor(LineNum, 3, MeTopColor);
		LTopList->SetItemColor(LineNum, 4, MeTopColor);
		LTopList->SetItemColor(LineNum, 5, MeTopColor);

	}
	else if (Total) {
		LTopList->SetItemColor(LineNum, 0, TotalColor);
		LTopList->SetItemColor(LineNum, 1, TotalColor);
		LTopList->SetItemColor(LineNum, 2, TotalColor);
		LTopList->SetItemColor(LineNum, 3, TotalColor);
		LTopList->SetItemColor(LineNum, 4, TotalColor);
		LTopList->SetItemColor(LineNum, 5, TotalColor);

	}
	 if (entrySpawn && entrySpawn->Type == SPAWN_PLAYER) {
		//WriteChatf("Setting Raid Color: %i, %i, %i", Ent->Class, Coloring[Ent->Class], ((PEQRAIDWINDOW)pRaidWnd)->ClassColors[ClassInfo.RaidColorOrder[Ent->Class]]);
		LTopList->SetItemColor(LineNum, 0, MeColor);
		LTopList->SetItemColor(LineNum, 1, MeColor);
		LTopList->SetItemColor(LineNum, 2, MeColor);
		LTopList->SetItemColor(LineNum, 3, MeColor);
		LTopList->SetItemColor(LineNum, 4, MeColor);
		LTopList->SetItemColor(LineNum, 5, MeColor);

	}
	else {
		LTopList->SetItemColor(LineNum, 0, NormalColor);
		LTopList->SetItemColor(LineNum, 1, NPCColor);
		LTopList->SetItemColor(LineNum, 2, NormalColor);
		LTopList->SetItemColor(LineNum, 3, NormalColor);
		LTopList->SetItemColor(LineNum, 4, NormalColor);
		LTopList->SetItemColor(LineNum, 5, NormalColor);
	}
}

void CDPSAdvWnd::SaveLoc() {
	if (!GetCharInfo()) return;

	PCHARINFO2 MyInfo2 = GetCharInfo2();
	PSPAWNINFO MySpawn = ((PSPAWNINFO)pCharSpawn);

	char szFileName[256] = "";

	if (MySpawn && MyInfo2)
	{
		sprintf_s(szFileName, "UI_%s_%s.ini", MySpawn->Name, EQADDR_SERVERNAME);
	}

	char szFileIncPathName[MAX_PATH] = "";

	if (GetFullPathName(szFileName, 256, szFileIncPathName, NULL))
	{
		CHAR szTemp[MAX_STRING] = { 0 };
		WritePrivateProfileString(GetCharInfo()->Name, "Saved", "1", szFileIncPathName);
		sprintf_s(szTemp, "%i", Location.top);
		WritePrivateProfileString(GetCharInfo()->Name, "Top", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", Location.bottom);
		WritePrivateProfileString(GetCharInfo()->Name, "Bottom", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", Location.left);
		WritePrivateProfileString(GetCharInfo()->Name, "Left", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", Location.right);
		WritePrivateProfileString(GetCharInfo()->Name, "Right", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", Alpha);
		WritePrivateProfileString(GetCharInfo()->Name, "Alpha", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", FadeToAlpha);
		WritePrivateProfileString(GetCharInfo()->Name, "FadeToAlpha", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", CListType);
		WritePrivateProfileString(GetCharInfo()->Name, "CListType", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", LiveUpdate ? 1 : 0);
		WritePrivateProfileString(GetCharInfo()->Name, "LiveUpdate", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", dShow);
		WritePrivateProfileString(GetCharInfo()->Name, "Show", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", ShowMeTop ? 1 : 0);
		WritePrivateProfileString(GetCharInfo()->Name, "ShowMeTop", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", ShowMeMin ? 1 : 0);
		WritePrivateProfileString(GetCharInfo()->Name, "ShowMeMin", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", ShowMeMinNum);
		WritePrivateProfileString(GetCharInfo()->Name, "ShowMeMinNum", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", ClearAfterCombat ? 1 : 0);
		WritePrivateProfileString(GetCharInfo()->Name, "ClearAfterCombat", szTemp, szFileIncPathName);
		sprintf_s(szTemp, "%i", EntTO);
		WritePrivateProfileString(GetCharInfo()->Name, "EntTO", szTemp, szFileIncPathName);
	}
}

void CDPSAdvWnd::LoadSettings() {
	CHAR szTemp[MAX_STRING] = { 0 };
	CShowMeTop->Checked = ShowMeTop ? 1 : 0;
	CShowMeMin->Checked = ShowMeMin ? 1 : 0;
	sprintf_s(szTemp, "%i", ShowMeMinNum);
	SetCXStr(&TShowMeMin->InputText, szTemp);
	CClearAfterCombatBox->Checked = ClearAfterCombat ? 1 : 0;
	CLiveUpdate->Checked = LiveUpdate ? 1 : 0;
	sprintf_s(szTemp, "%i", EntTO);
	SetCXStr(&TEntTO->InputText, szTemp);
	CShowTotal->DeleteAll();
	CShowTotal->InsertChoice("Don't Show Total");
	CShowTotal->InsertChoice("Above ShowMeTop");
	CShowTotal->InsertChoice("Below ShowMeTop");
	CShowTotal->InsertChoice("Show Bottom");
	CShowTotal->InsertChoice("");
	CShowTotal->SetChoice(ShowTotal);
}

void CDPSAdvWnd::LoadLoc(char szChar[256]) {
	if (!GetCharInfo()) return;

	PCHARINFO2 MyInfo2 = GetCharInfo2();
	PSPAWNINFO MySpawn = ((PSPAWNINFO)pCharSpawn);

	char szFileName[256] = "";

	if (MySpawn && MyInfo2)
	{
		sprintf_s(szFileName, "UI_%s_%s.ini", MySpawn->Name, EQADDR_SERVERNAME);
	}

	char szFileIncPathName[MAX_PATH] = "";

	if (GetFullPathName(szFileName, 256, szFileIncPathName, NULL))
	{

		char szName[256] = { 0 };
		if (!szChar) strcpy_s(szName, GetCharInfo()->Name);
		else strcpy_s(szName, szChar);
		Saved = (GetPrivateProfileInt(szName, "Saved", 0, szFileIncPathName) > 0 ? true : false);
		if (Saved && DPSWnd) {
			DPSWnd->Location = { (LONG)GetPrivateProfileInt(szName, "Left", 0, szFileIncPathName),
				(LONG)GetPrivateProfileInt(szName, "Top", 0, szFileIncPathName),
				(LONG)GetPrivateProfileInt(szName, "Right", 0, szFileIncPathName),
				(LONG)GetPrivateProfileInt(szName, "Bottom", 0, szFileIncPathName) };

			DPSWnd->Alpha = (BYTE)GetPrivateProfileInt(szName, "Alpha", 0, szFileIncPathName);

			DPSWnd->FadeToAlpha = (BYTE)GetPrivateProfileInt(szName, "FadeToAlpha", 0, szFileIncPathName);
		}
		CListType = GetPrivateProfileInt(szName, "CListType", 0, szFileIncPathName);
		LiveUpdate = (GetPrivateProfileInt(szName, "LiveUpdate", 0, szFileIncPathName) > 0 ? true : false);
		Debug = (GetPrivateProfileInt(szName, "Debug", 0, szFileIncPathName) > 0 ? true : false);
		if (DPSWnd)
			DPSWnd->dShow = (GetPrivateProfileInt(szName, "Show", 1, szFileIncPathName) > 0 ? true : false);
		ShowMeTop = (GetPrivateProfileInt(szName, "ShowMeTop", 0, szFileIncPathName) > 0 ? true : false);
		ShowMeMin = (GetPrivateProfileInt(szName, "ShowMeMin", 0, szFileIncPathName) > 0 ? true : false);
		ShowMeMinNum = GetPrivateProfileInt(szName, "ShowMeMinNum", 0, szFileIncPathName);
		ClearAfterCombat = (GetPrivateProfileInt(szName, "ClearAfterCombat", 0, szFileIncPathName) > 0 ? true : false);
		ShowTotal = GetPrivateProfileInt(szName, "ShowTotal", 0, szFileIncPathName);
		EntTO = GetPrivateProfileInt(szName, "EntTO", 8, szFileIncPathName);
		MeColor = GetPrivateProfileInt(szName, "MeColor", 0xFF00CC00, szFileIncPathName);
		MeTopColor = GetPrivateProfileInt(szName, "MeTopColor", 0xFF00CC00, szFileIncPathName);
		NormalColor = GetPrivateProfileInt(szName, "NormalColor", 0xFFFFFFFF, szFileIncPathName);
		NPCColor = GetPrivateProfileInt(szName, "NPCColor", 0xFFFFFFFF, szFileIncPathName);
		TotalColor = GetPrivateProfileInt(szName, "TotalColor", 0xFF66FFFF, szFileIncPathName);
		EntHover = GetPrivateProfileInt(szName, "EntHover", 0xFFCC3333, szFileIncPathName);
		EntHighlight = GetPrivateProfileInt(szName, "EntHighlight", 0xFF666666, szFileIncPathName);
		FightNormal = GetPrivateProfileInt(szName, "FightNormal", NormalColor, szFileIncPathName);
		FightHover = GetPrivateProfileInt(szName, "FightHover", EntHover, szFileIncPathName);
		FightHighlight = GetPrivateProfileInt(szName, "FightHighlight", EntHighlight, szFileIncPathName);
		FightActive = GetPrivateProfileInt(szName, "FightActive", 0xFF00CC00, szFileIncPathName);
		FightInActive = GetPrivateProfileInt(szName, "FightInActive", 0xFF777777, szFileIncPathName);
		FightDead = GetPrivateProfileInt(szName, "FightDead", 0xFF330000, szFileIncPathName);
		if (EntTO < 3) EntTO = 15;
		if (Debug) gSpewToFile = TRUE;
		if (CListType > 1) CListType = CLISTTARGET;
		LTopList->SetColors(NormalColor, EntHover, EntHighlight);
		//   LFightList->SetColors(FightNormal, FightHover, FightHighlight);
		CMobList->SetChoice(CListType);
		LoadSettings();
	}
}

int CDPSAdvWnd::WndNotification(CXWnd *pWnd, unsigned int Message, void *unknown) {
	if (Debug && Message != 21) WriteChatf("Notify: %i", Message);
	if (Message == 10) CheckActive();
	if (Message == 3 && pWnd == (CXWnd*)LTopList) LTopList->SetCurSel(-1);
	else if (Message == 10 && pWnd == (CXWnd*)DPSWnd) CheckActive();
	else if (Message == 1) {
		if (pWnd == (CXWnd*)Tabs) LoadSettings();
		else if (pWnd == (CXWnd*)CShowMeTop) ShowMeTop = CShowMeTop->Checked ? true : false;
		else if (pWnd == (CXWnd*)CShowMeMin) ShowMeMin = CShowMeMin->Checked ? true : false;
		else if (pWnd == (CXWnd*)CClearAfterCombatBox) ClearAfterCombat = CClearAfterCombatBox->Checked ? true : false;
		else if (pWnd == (CXWnd*)CLiveUpdate) LiveUpdate = CLiveUpdate->Checked ? true : false;
		//else if (pWnd == (CXWnd*)LTopList) WriteChatf("CurSel: %i", LTopList->GetCurSel());
		else if (pWnd == (CXWnd*)CShowTotal) {
			ShowTotal = CShowTotal->GetCurChoice();
			if (ShowTotal == 4) ShowTotal = 0;
			LoadSettings();
		}
		else if (pWnd == (CXWnd*)CMobList) {
			CurListMob = 0;
			LTopList->DeleteAll();
			bool FoundMob = false;
			if ((int)CMobList->GetCurChoice() > 1) {
				CListType = 2;
				int i = 0, x = 0;
				for (auto mob : DamageEntries) {
					auto ListMob = (PSPAWNINFO)GetSpawnByID(mob.first);
					if (ListMob && ListMob->Type == 1 && !ListMob->PetID != 0) {
						if (x + 2 == (int)CMobList->GetCurChoice()) {
							FoundMob = true;
							ListSwitch(ListMob);
							break;
						}
						x++;
					}
				}
				if (!FoundMob) {
					CListType = 0;
					DPSWnd->DrawCombo();
				}
			}
			else CListType = (int)CMobList->GetCurChoice();
			Intervals -= 1; // Force update next Pulse.
		}
	}
	else if (Message == 14) {
		CHAR szTemp[MAX_STRING] = { 0 };
		GetCXStr(((CEditWnd*)pWnd)->InputText, szTemp);
		if (pWnd == (CXWnd*)TShowMeMin) {
			if (strlen(szTemp)) {
				szTemp[2] = 0;
				ShowMeMinNum = atoi(szTemp);
				sprintf_s(szTemp, "%i", ShowMeMinNum);
				SetCXStr(&TShowMeMin->InputText, szTemp);
				TShowMeMin->SetSel(strlen(szTemp), 0);
			}
		}
		else if (pWnd == (CXWnd*)TEntTO) {
			if (strlen(szTemp)) {
				szTemp[2] = 0;
				EntTO = atoi(szTemp);
				if (EntTO < 3) EntTO = 15;
				sprintf_s(szTemp, "%i", EntTO);
				//SetCXStr(&TEntTO->InputText, szTemp);
				//TEntTO->SetSel(strlen(szTemp), 0);
			}
		}
	}

	return CSidlScreenWnd::WndNotification(pWnd, Message, unknown);
};


#ifdef DPSDEV
void DPSTestCmd(PSPAWNINFO pChar, PCHAR szLine) {

}
#endif

void DPSAdvCmd(PSPAWNINFO pChar, PCHAR szLine) {
	char Arg1[MAX_STRING];
	GetArg(Arg1, szLine, 1);
	if (!_stricmp(Arg1, "show"))
		if (!DPSWnd) WriteChatf("\arDPSWnd does not exist. Try reloading your UI (/loadskin default).");
		else DPSWnd->dShow  = DPSWnd->dShow;
	else if (DPSWnd && !_stricmp(Arg1, "reload"))
		DPSWnd->LoadLoc();
	else if (DPSWnd && !_stricmp(Arg1, "save"))
		DPSWnd->SaveLoc();
#ifdef DPSDEBUG
	else if (!_stricmp(Arg1, "listsize"))
		WriteChatf("\ayMobList Size: %i", DamageEntries.size());
#endif
	CheckActive();
}

void CreateDPSWindow() {
	if (DPSWnd) DestroyDPSWindow();
	if (pSidlMgr->FindScreenPieceTemplate("DPSAdvWnd")) {
		DPSWnd = new CDPSAdvWnd();
		if (DPSWnd->dShow) ((CXWnd*)DPSWnd)->Show(1, 1);
		char szTitle[MAX_STRING];
		sprintf_s(szTitle, "DPS Window %s", DPSVERSION);
		SetCCXStr(&DPSWnd->WindowText, szTitle);
	}
	CheckActive();
}

void DestroyDPSWindow() {
	if (DPSWnd) {
		ZoneProcess();
		DPSWnd->SaveLoc();
		delete DPSWnd;
		DPSWnd = 0;
	}
	CheckActive();
	bCleaned = true;
}

PLUGIN_API VOID SetDPSGameState(DWORD GameState) {
	//DebugSpewAlways("GameState Change: %i", GameState);
	if (GameState == GAMESTATE_INGAME) {
		if (!DPSWnd) CreateDPSWindow();
	}
}
PLUGIN_API VOID OnDPSCleanUI(VOID) { DestroyDPSWindow(); bCleaned = true; }
PLUGIN_API VOID OnDPSReloadUI(VOID) { if (gGameState == GAMESTATE_INGAME && pCharSpawn) CreateDPSWindow(); }

PLUGIN_API VOID InitializeDPSPlugin(VOID) {
	LastMob = 0;
	CurTarget = 0;
	CurTarMob = 0;
	CurListMob = 0;
	CurMaxMob = 0;
	Zoning = false;
	ShowMeTop = false;
	WrongUI = false;
	CheckActive();
}

PLUGIN_API VOID ShutdownDPSPlugin(VOID) {
	DestroyDPSWindow();
#ifdef DPSDEV
	RemoveCommand("/dpstest");
#endif
}

bool CheckInterval() {
	if (!Intervals) Intervals = time(NULL);
	else if (Intervals != time(NULL)) {
		Intervals = time(NULL);
		return true;
	}
	return false;
}

void CheckActive() {
	if (DPSWnd && DPSWnd->dShow && !Zoning && !WrongUI) Active = true;
	else Active = false;
}

void ListSwitch(PSPAWNINFO Switcher) {
	if (Switcher)
	{
		CurListMob = Switcher;
	}
	DPSWnd->LTopList->SetCurSel(-1);
	DPSWnd->LTopList->VScrollPos = 0;
	DPSWnd->DrawList();
	DPSWnd->DrawCombo();
}

void TargetSwitch() {
	CurTarget = (PSPAWNINFO)pTarget;
	ListSwitch(CurTarget);
}

void HandleDeath(EdgeDPSEntry DeadMob) {

	DPSWnd->DrawList();
}

void IntPulse() {
	bool CChange = false;

	std::map<uint32_t, EdgeDPSEntry> DamageEntryClone(DamageEntries);

	for (auto entry : DamageEntryClone) {
		auto spawnEntry = (PSPAWNINFO)GetSpawnByID(entry.first);

		auto timestamp = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed_without_record = timestamp - entry.second.LastUpdateTimestamp;

		if (elapsed_without_record.count() >= (double)EntTO)
		{
			auto found = DamageEntries.find(entry.second.SpawnID);

			if (found != DamageEntries.end())
			{
				DamageEntries.erase(found);
			}
			continue;
		}
	}
	if (CListType == CLISTMAXDMG && CurMaxMob && CurMaxMob != CurListMob) 
		ListSwitch(CurMaxMob);
	if (CChange) 
		DPSWnd->DrawCombo();
	DPSWnd->DrawList();
	//WriteChatf("Active: %s", Active ? "Yes" : "No");
}

PLUGIN_API VOID OnDPSPulse(VOID) {
	if (gGameState != GAMESTATE_INGAME || !pCharSpawn) return;

	if (gGameState == GAMESTATE_INGAME && pCharSpawn) {
		if (!DPSWnd && !Zoning)
			CreateDPSWindow();
	}

	if (Active) {
		if (DPSWnd)
		{
			if (DPSWnd->dShow) ((CXWnd*)DPSWnd)->Show(1, 1);
			if ((PSPAWNINFO)pTarget && (PSPAWNINFO)pTarget != CurTarget) TargetSwitch();
			if (CListType == CLISTTARGET && CurTarMob && CurTarMob != CurListMob)
			{
				auto entry = GetEdgeDPSEntryByID(CurTarMob->SpawnID, false);
				if (entry.SpawnID && entry.weDamaged)
				{
					ListSwitch(CurTarMob);
				}
			}
			if (CheckInterval()) IntPulse();
		}
	}
}

PLUGIN_API VOID OnDPSBeginZone(VOID) {
	//DebugSpewAlways("START ZONING");
	ZoneProcess();
	Zoning = true;
	CheckActive();
}

PLUGIN_API VOID OnDPSEndZone(VOID) {
	//DebugSpewAlways("END ZONING");
	Zoning = false;
	CheckActive();
}
