#include "vault_window.h"
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

extern void AddXMLFile(const char *filename);

VaultWnd* VaultWnd::s_instance = nullptr;

// VAULTDATA|CLEAR and the ADD rows that follow it arrive before (or without) a live
// window, so the in-flight burst has to be gathered outside the instance and is
// committed to it on VAULTDATA|OPEN.
static std::vector<VaultItemData> s_pending;

VaultWnd* VaultWnd::GetInstance() {
	return s_instance;
}

VaultWnd::VaultWnd() : CCustomWnd("VaultWnd") {
	m_pVaultList = (CListWnd*)GetChildItem("VaultList");
	m_pDepositButton = (CButtonWnd*)GetChildItem("DepositButton");
	m_pWithdrawButton = (CButtonWnd*)GetChildItem("WithdrawButton");
	m_pBankButton = (CButtonWnd*)GetChildItem("BankButton");
	m_pMerchantButton = (CButtonWnd*)GetChildItem("MerchantButton");
	for (int i = 0; i < 9; ++i) {
		char name[16];
		sprintf_s(name, sizeof(name), "Page%d", i + 1);
		m_pPageButtons[i] = (CButtonWnd*)GetChildItem(name);
	}
	m_pDescriptionLabel = GetChildItem("DescriptionLabel");

	if (!m_pVaultList) WriteChatf("[Vault] Failed to find VaultList!");
	if (!m_pDepositButton) WriteChatf("[Vault] Failed to find DepositButton!");
	if (!m_pWithdrawButton) WriteChatf("[Vault] Failed to find WithdrawButton!");

	SetWndNotification(VaultWnd);

	m_open_page = 1;

	// The SIDL template carries no <Title>, so the titlebar is named here.
	CXStr title("Nautilus Vault");
	pXWnd()->SetWindowTextA(title);
}

VaultWnd::~VaultWnd() {
}

void VaultWnd::Initialize() {
	AddXMLFile("NMS_VaultWnd.xml");
}

void VaultWnd::Shutdown() {
	if (s_instance) {
		((CXWnd*)s_instance)->Show(false, false);
		delete s_instance;
		s_instance = nullptr;
	}
	s_pending.clear();
}

void VaultWnd::OnSetGameState(int state) {
	if (state != 5 && s_instance) {
		((CXWnd*)s_instance)->Show(false, false);
	}
}

static int SplitFields(const char* s, std::vector<std::string>& out) {
	out.clear();
	const char* p = s;
	while (true) {
		const char* bar = strchr(p, '|');
		if (bar) {
			out.push_back(std::string(p, bar - p));
			p = bar + 1;
		} else {
			out.push_back(std::string(p));
			break;
		}
	}
	return (int)out.size();
}

void VaultWnd::OnIncomingChat(const char* line) {
	if (!line || strncmp(line, "VAULTDATA|", 10) != 0) {
		return;
	}

	const char* rest = line + 10;
	if (strncmp(rest, "CLEAR", 5) == 0) {
		s_pending.clear();
		return;
	}

	if (strncmp(rest, "ADD|", 4) == 0) {
		std::vector<std::string> fields;
		if (SplitFields(rest + 4, fields) != 15) {
			return;
		}

		VaultItemData item;
		item.page = atoi(fields[0].c_str());
		item.slot = atoi(fields[1].c_str());
		item.item_id = (uint32_t)strtoul(fields[2].c_str(), NULL, 10);
		item.charges = atoi(fields[3].c_str());
		item.icon = (uint32_t)strtoul(fields[4].c_str(), NULL, 10);
		item.name = fields[5];
		item.bag_contents = fields[6];
		for (int i = 0; i < 6; ++i) {
			item.aug[i] = (uint32_t)strtoul(fields[7 + i].c_str(), NULL, 10);
		}
		item.nodrop = atoi(fields[13].c_str()) != 0;
		item.bag_slots = atoi(fields[14].c_str());
		s_pending.push_back(item);
		return;
	}

	if (strncmp(rest, "OPEN|", 5) == 0) {
		int page = atoi(rest + 5);
		if (page < 1) {
			page = 1;
		}

		if (!pSidlMgr->FindScreenPieceTemplate("VaultWnd")) {
			WriteChatf("[Vault] Template 'VaultWnd' not found! UI reload may be needed.");
			s_pending.clear();
			return;
		}

		if (!s_instance) {
			s_instance = new VaultWnd();
		}

		if (s_instance) {
			s_instance->m_items = s_pending;
			s_instance->m_open_page = page;
			s_instance->PopulateList();
			((CXWnd*)s_instance)->Show(true, true);
		}
		s_pending.clear();
		return;
	}
}

static int CountBagItems(const std::string& bag_contents) {
	if (bag_contents.empty()) {
		return 0;
	}
	int count = 1;
	for (size_t i = 0; i < bag_contents.size(); ++i) {
		if (bag_contents[i] == '~') {
			++count;
		}
	}
	return count;
}

void VaultWnd::PopulateList() {
	if (!m_pVaultList) {
		return;
	}
	m_pVaultList->DeleteAll();

	int first;
	int last;
	if (m_open_page >= 1 && m_open_page <= 6) {
		first = (m_open_page - 1) * 10 + 1;
		last = first + 9;
	} else if (m_open_page == 7) {
		first = 61;
		last = 70;
	} else if (m_open_page == 8) {
		first = 71;
		last = 80;
	} else {
		first = 81;
		last = 83;
	}

	for (int slot = first; slot <= last; ++slot) {
		const VaultItemData* item = FindSlot(slot);

		char slot_text[16];
		sprintf_s(slot_text, sizeof(slot_text), "%d", slot);

		CXStr col_slot(slot_text);
		CXStr col_name;
		CXStr col_qty;
		DWORD color = 0xFFFFFFFF;

		if (!item) {
			if (m_open_page == 9) {
				if (slot == 81) col_name = "<Empty Primary Proc Slot>";
				else if (slot == 82) col_name = "<Empty Secondary Proc Slot>";
				else col_name = "<Empty Ranged Proc Slot>";
			} else {
				col_name = "<Empty Vault Slot>";
			}
			color = 0xFFA0A0A0;
		} else {
			col_name = item->name.c_str();
			if (item->bag_slots > 0) {
				char qty[32];
				sprintf_s(qty, sizeof(qty), "%d items", CountBagItems(item->bag_contents));
				col_qty = qty;
			} else if (item->charges > 1) {
				char qty[16];
				sprintf_s(qty, sizeof(qty), "%d", item->charges);
				col_qty = qty;
			}
			if (item->nodrop) {
				color = 0xFFFF4040;
			}
		}

		int index = m_pVaultList->AddString("", color, (uint32_t)slot, 0);
		if (index == -1) {
			continue;
		}
		m_pVaultList->SetItemText(index, 1, &col_slot);
		m_pVaultList->SetItemText(index, 2, &col_name);
		m_pVaultList->SetItemText(index, 3, &col_qty);
	}
}

const VaultItemData* VaultWnd::FindSlot(int slot) const {
	for (size_t i = 0; i < m_items.size(); ++i) {
		if (m_items[i].slot == slot) {
			return &m_items[i];
		}
	}
	return nullptr;
}

void VaultWnd::UpdateDescription() {
	if (!m_pDescriptionLabel) {
		return;
	}

	CXStr text("");
	if (m_pVaultList) {
		int sel = m_pVaultList->GetCurSel();
		if (sel != -1) {
			const VaultItemData* item = FindSlot((int)m_pVaultList->GetItemData(sel));
			if (item) {
				if (item->bag_slots > 0 && !item->bag_contents.empty()) {
					// Server field format: groups of item_id:name:charges:icon joined by ~.
					std::string desc = "Contains: ";
					size_t pos = 0;
					bool first_group = true;
					while (pos <= item->bag_contents.size()) {
						size_t tilde = item->bag_contents.find('~', pos);
						std::string group = item->bag_contents.substr(pos,
							(tilde == std::string::npos) ? std::string::npos : (tilde - pos));
						size_t c1 = group.find(':');
						size_t c2 = (c1 == std::string::npos) ? std::string::npos : group.find(':', c1 + 1);
						if (c1 != std::string::npos && c2 != std::string::npos) {
							std::string gname = group.substr(c1 + 1, c2 - c1 - 1);
							int gcharges = atoi(group.c_str() + c2 + 1);
							if (!first_group) {
								desc += ", ";
							}
							char qty[24];
							sprintf_s(qty, sizeof(qty), " x%d", gcharges > 0 ? gcharges : 1);
							desc += gname + qty;
							first_group = false;
						}
						if (tilde == std::string::npos) {
							break;
						}
						pos = tilde + 1;
					}
					text = desc.c_str();
				} else if (item->charges > 1) {
					char desc[256];
					sprintf_s(desc, sizeof(desc), "%s (charges: %d)", item->name.c_str(), item->charges);
					text = desc;
				} else {
					text = item->name.c_str();
				}
			}
		}
	}
	((CXWnd*)this)->SetWindowTextA(text);
}

void VaultWnd::SendServerCommand(const char* format, ...) {
	char buffer[512];
	va_list args;
	va_start(args, format);
	_vsnprintf_s(buffer, sizeof(buffer), _TRUNCATE, format, args);
	va_end(args);
	buffer[sizeof(buffer) - 1] = '\0';

	if (pEverQuest && pLocalPlayer) {
		pEverQuest->InterpretCmd((EQPlayer*)pLocalPlayer, buffer);
	}
}

int VaultWnd::WndNotification(CXWnd* pWnd, unsigned int Message, void* data) {
	if (Message == XWM_LCLICK) {
		if (m_pVaultList && pWnd == (CXWnd*)m_pVaultList) {
			UpdateDescription();
		}
		else if (m_pDepositButton && pWnd == (CXWnd*)m_pDepositButton) {
			if (m_pVaultList) {
				int sel = m_pVaultList->GetCurSel();
				if (sel != -1) {
					SendServerCommand("#vault_deposit %d", (int)m_pVaultList->GetItemData(sel));
				} else {
					WriteChatf("[Vault] Select a slot first, then put the item on your cursor.");
				}
			}
		}
		else if (m_pWithdrawButton && pWnd == (CXWnd*)m_pWithdrawButton) {
			if (m_pVaultList) {
				int sel = m_pVaultList->GetCurSel();
				if (sel != -1) {
					int slot = (int)m_pVaultList->GetItemData(sel);
					if (FindSlot(slot)) {
						SendServerCommand("#vault_withdraw %d", slot);
					}
				} else {
					WriteChatf("[Vault] Select an item to withdraw first.");
				}
			}
		}
		else if (m_pBankButton && pWnd == (CXWnd*)m_pBankButton) {
			// The RoF2 client only opens the native bank window itself when a banker is
			// right-clicked; a server-sent OP_BankerChange alone does not open it (stock
			// EQEmu never sends one - the client drives). Activate it here exactly like
			// the original add-on did (it imported CBankWnd__Activate / ppBankWnd), then
			// let the server authorize vault-bank moves and send current coin balances.
			if (ppBankWnd && *ppBankWnd) {
				(*ppBankWnd)->Activate((EQPlayer*)pLocalPlayer);
			}
			else {
				WriteChatf("[Vault] The bank window is not available yet - reload the UI or re-zone once.");
			}
			SendServerCommand("#vault_bank");
		}
		else if (m_pMerchantButton && pWnd == (CXWnd*)m_pMerchantButton) {
			SendServerCommand("#vault_merchant");
		}
		else if (pWnd) {
			for (int i = 0; i < 9; ++i) {
				if (m_pPageButtons[i] && pWnd == (CXWnd*)m_pPageButtons[i]) {
					SendServerCommand("#vault_page %d", i + 1);
					break;
				}
			}
		}
	}
	return CSidlScreenWnd::WndNotification(pWnd, Message, data);
}
