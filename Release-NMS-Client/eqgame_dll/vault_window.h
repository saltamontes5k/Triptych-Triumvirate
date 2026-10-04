#pragma once
#include "MQ2Main.h"
#include <vector>
#include <string>

// One row of vault state as sent by the server's VAULTDATA|ADD protocol line
// (17 pipe-separated fields: VAULTDATA|ADD|page|slot|item_id|charges|icon|name|
//  bag_contents|aug1..aug6|nodrop|bagslots). The client add-on owns this side of
// the wire, so the struct mirrors the server format rather than any native layout.
struct VaultItemData {
	int page;
	int slot;
	uint32_t item_id;
	int charges;
	uint32_t icon;
	std::string name;
	std::string bag_contents;
	uint32_t aug[6];
	bool nodrop;
	int bag_slots;

	VaultItemData()
		: page(0), slot(0), item_id(0), charges(0), icon(0),
		  nodrop(false), bag_slots(0)
	{
		aug[0] = aug[1] = aug[2] = aug[3] = aug[4] = aug[5] = 0;
	}
};

class VaultWnd : public CCustomWnd {
public:
	VaultWnd();
	~VaultWnd();

	int WndNotification(CXWnd* pWnd, unsigned int Message, void* data);

	static void Initialize();
	static void Shutdown();
	// Feed every incoming chat line through here; only bare "VAULTDATA|" protocol
	// lines are consumed, human chat (including the [NMS] prefixed text) is ignored.
	static void OnIncomingChat(const char* line);
	static void OnSetGameState(int state);
	static VaultWnd* GetInstance();

	void PopulateList();

private:
	static VaultWnd* s_instance;

	CListWnd* m_pVaultList;
	CButtonWnd* m_pDepositButton;
	CButtonWnd* m_pWithdrawButton;
	CButtonWnd* m_pBankButton;
	CButtonWnd* m_pMerchantButton;
	CButtonWnd* m_pPageButtons[9];
	CXWnd* m_pDescriptionLabel;

	int m_open_page;
	std::vector<VaultItemData> m_items;

	const VaultItemData* FindSlot(int slot) const;
	void UpdateDescription();
	static void SendServerCommand(const char* format, ...);
};
