// Brovil / DoDH notebook opener gate.
// Intercepted at OP_TradeAcceptClick before the generic trade path. One row per
// character in dodh_brovil_receipts; a repeat returns the notebook, the first
// hand-in consumes it in the same strict transaction as the receipt insert.
// No opcode and no client contract.
#pragma once

namespace DodhBrovilGate {

namespace {
constexpr uint32_t OpenerNpc = 365275;
constexpr uint32_t OpenerSpawn = 103414;
constexpr uint32_t OpenerZone = 365;
constexpr uint32_t Notebook = 84040;

bool IsOpener(NPC &npc)
{
    return zone && zone->GetZoneID() == OpenerZone && !zone->GetInstanceID() &&
        !zone->GetInstanceVersion() && npc.GetNPCTypeID() == OpenerNpc &&
        npc.GetSpawnPointID() == OpenerSpawn && npc.GetHP() > 0 && !npc.GetDepop() &&
        entity_list.GetNPCByID(npc.GetID()) == &npc;
}

void Finish(Client &client)
{
    client.trade->Reset();
    auto packet = std::make_unique<EQApplicationPacket>(OP_FinishTrade, 0);
    client.QueuePacket(packet.get());
}

bool ReturnNotebook(Client &client, int16_t slot, EQ::ItemInstance *item)
{
    if (!client.GetInv().CursorEmpty() || !client.PushItemOnCursor(*item, true)) {
        client.GetInv().PushItem(slot, item);
        client.Message(Chat::Yellow, "Make room on your cursor for the Torn Notebook.");
        return true;
    }
    if (!database.SaveInventory(client.CharacterID(), nullptr, slot)) {
        LogError("Brovil opener: cursor return saved but trade-slot [{}] row did not clear for [{}]",
            slot, client.GetCleanName());
    }
    safe_delete(item);
    Finish(client);
    client.Message(Chat::Yellow, "You have already turned in a notebook. Your offer was returned.");
    return true;
}
} // namespace

// Returns true only when this handler owns the attempt (including a refusal).
bool HandleTradeAccept(Client &client, Mob *with)
{
    if (!with || !with->IsNPC() || !client.trade) return false;
    NPC *npc = with->CastToNPC();
    if (!npc || !IsOpener(*npc)) return false;

    int16_t notebook_slot = -1;
    bool extra = false;
    for (int16_t slot = EQ::invslot::TRADE_BEGIN; slot <= EQ::invslot::TRADE_NPC_END; ++slot) {
        auto *item = client.GetInv().GetItem(slot);
        if (!item) continue;
        if (item->GetID() == Notebook && notebook_slot < 0) {
            notebook_slot = slot;
        } else {
            extra = true;
        }
    }
    if (notebook_slot < 0) return false; // not this gate's offer
    if (extra) {
        client.Message(Chat::Yellow, "Offer only the Torn Notebook to Model XG CVIII.");
        return true; // leave the window open so the player can remove the other items
    }
    if (!client.GetInv().CursorEmpty()) {
        client.Message(Chat::Yellow, "Empty your cursor before the notebook hand-in.");
        return true;
    }

    auto receipt = database.QueryDatabase(
        "SELECT 1 FROM dodh_brovil_receipts WHERE character_id=" +
        std::to_string(client.CharacterID()) + " LIMIT 1", false);
    if (!receipt.Success()) {
        client.Message(Chat::Yellow, "The notebook ledger is unavailable; your offer was not taken.");
        return true;
    }
    if (receipt.RowCount()) {
        auto *item = client.GetInv().PopItem(notebook_slot);
        if (!item) return true;
        return ReturnNotebook(client, notebook_slot, item);
    }

    auto *item = client.GetInv().PopItem(notebook_slot);
    if (!item) return true;
    if (!database.TransactionBeginStrict().Success()) {
        client.GetInv().PushItem(notebook_slot, item);
        client.Message(Chat::Yellow, "The notebook hand-in could not start; your offer was not taken.");
        return true;
    }
    const auto actor = std::to_string(client.CharacterID());
    auto debit = database.QueryDatabase(
        "DELETE FROM inventory WHERE character_id=" + actor + " AND slot_id=" +
        std::to_string(notebook_slot), false);
    auto insert = database.QueryDatabase(
        "INSERT INTO dodh_brovil_receipts(character_id,settled_at,source_guid,npc_type_id,npc_spawn_id) VALUES(" +
        actor + ",UNIX_TIMESTAMP()," + std::to_string(item->GetSerialNumber()) + "," +
        std::to_string(OpenerNpc) + "," + std::to_string(OpenerSpawn) + ")", false);
    if (!debit.Success() || debit.RowsAffected() != 1 || !insert.Success() ||
        !database.TransactionCommitStrict().Success()) {
        database.TransactionRollbackStrict();
        client.GetInv().PushItem(notebook_slot, item);
        client.Message(Chat::Yellow, "The notebook hand-in was not recorded; your offer was not taken.");
        return true;
    }

    safe_delete(item);
    Finish(client);
    client.Message(Chat::Yellow, "Your Torn Notebook has been recorded.");
    return true;
}

} // namespace DodhBrovilGate
