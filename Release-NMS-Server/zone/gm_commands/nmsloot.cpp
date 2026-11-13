#include "../client.h"
#include "../nms_loot_offers.h"
#include "../../common/eq_packet.h"
#include "../../common/eq_packet_structs.h"

// GM test path: apply a decision exactly as if the window had sent it
// (module actions: 1 Keep, 2 Sell, 3 Tribute, 4 Bank, 5 Vault, 6 Destroy, 7 Pass, 9 Return)
void command_nmsloot_decide(Client *c, const Seperator *sep)
{
	if (!sep->IsNumber(1) || !sep->IsNumber(2)) {
		c->Message(Chat::White, "Usage: #nmsloot_decide [offer_id] [action 1-7 or 9] [pass_to]");
		return;
	}

	NmsLootDecision_Struct decision{};
	decision.offer_id = Strings::ToUnsignedInt(sep->arg[1]);
	decision.action = static_cast<uint8>(Strings::ToUnsignedInt(sep->arg[2]));
	if (sep->arg[3] && sep->arg[3][0]) {
		strn0cpy(decision.name, sep->arg[3], sizeof(decision.name));
	}

	auto app = new EQApplicationPacket(OP_NmsLootDecision, sizeof(NmsLootDecision_Struct));
	memcpy(app->pBuffer, &decision, sizeof(decision));
	NmsLootOfferHandleDecision(c, app);
	safe_delete(app);
}
