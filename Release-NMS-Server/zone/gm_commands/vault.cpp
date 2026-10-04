#include "../client.h"
#include "../nms_vault.h"

void command_vault_page(Client *c, const Seperator *sep)
{
	int page = 1;
	if (sep->IsNumber(1)) {
		page = Strings::ToInt(sep->arg[1]);
	}
	NmsVaultHandlePage(c, page);
}

void command_vault_deposit(Client *c, const Seperator *sep)
{
	if (!sep->IsNumber(1)) {
		c->Message(Chat::White, "Usage: #vault_deposit [slot]");
		return;
	}
	NmsVaultHandleDeposit(c, Strings::ToInt(sep->arg[1]));
}

void command_vault_withdraw(Client *c, const Seperator *sep)
{
	if (!sep->IsNumber(1)) {
		c->Message(Chat::White, "Usage: #vault_withdraw [slot] [1]");
		return;
	}
	const int quantity = sep->IsNumber(2) ? Strings::ToInt(sep->arg[2]) : 0;
	NmsVaultHandleWithdraw(c, Strings::ToInt(sep->arg[1]), quantity);
}

void command_vault_bank(Client *c, const Seperator *sep)
{
	(void) sep;
	NmsVaultHandleBank(c);
}

void command_vault_merchant(Client *c, const Seperator *sep)
{
	(void) sep;
	NmsVaultHandleMerchant(c);
}

void command_vault_deposit_bagitem_specific(Client *c, const Seperator *sep)
{
	if (!sep->IsNumber(1) || !sep->IsNumber(2)) {
		c->Message(Chat::White, "Usage: #vault_deposit_bagitem_specific [slot] [bagslot]");
		return;
	}
	NmsVaultHandleDepositBagItem(c, Strings::ToInt(sep->arg[1]), Strings::ToInt(sep->arg[2]));
}

void command_vault_withdraw_bagitem(Client *c, const Seperator *sep)
{
	if (!sep->IsNumber(1) || !sep->IsNumber(2)) {
		c->Message(Chat::White, "Usage: #vault_withdraw_bagitem [slot] [bagslot] [1]");
		return;
	}
	const int quantity = sep->IsNumber(3) ? Strings::ToInt(sep->arg[3]) : 0;
	NmsVaultHandleWithdrawBagItem(c, Strings::ToInt(sep->arg[1]), Strings::ToInt(sep->arg[2]), quantity);
}
