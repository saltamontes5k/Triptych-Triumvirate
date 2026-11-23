// Fall of Illsalin 920243 — full session/escrow service.
// Included at the end of client_spirit_shroud.cpp. Snapshots the 17 character
// tables into shroud_original_*, creates spirit_shroud_sessions + manifest, and
// restores atomically on exit. The form itself still rides EnterNativeShroud.
#pragma once
#include "corpse.h"

namespace {

struct FallEscrowTable { const char *name; const char *key; };
const FallEscrowTable FallEscrowTables[] = {
    {"character_data", "id"}, {"inventory", "character_id"}, {"character_currency", "id"},
    {"character_spells", "id"}, {"character_memmed_spells", "id"}, {"character_skills", "id"},
    {"character_alternate_abilities", "id"}, {"character_disciplines", "id"},
    {"character_buffs", "character_id"}, {"character_bandolier", "id"},
    {"character_potionbelt", "id"}, {"character_material", "id"},
    {"character_pet_info", "char_id"}, {"character_pet_buffs", "character_id"},
    {"character_pet_inventory", "char_id"}, {"character_item_recast", "id"},
    {"timers", "char_id"},
};

std::string FallWhere(const FallEscrowTable &table, uint32_t character)
{
    return std::string(" WHERE ") + table.key + "=" + S(character);
}

void FallManifest(Database &db, uint64_t session, uint32_t character)
{
    for (const auto &table : FallEscrowTables) {
        const auto where = FallWhere(table, character);
        auto count = Q(db, std::string("SELECT COUNT(*) FROM shroud_original_") + table.name + where);
        Q(db, "INSERT INTO spirit_shroud_snapshot_manifest(session_id,table_name,row_count) VALUES(" +
            S(session) + ",'" + table.name + "'," + S(N(count.begin()[0])) + ")");
    }
}

void FallSnapshot(Database &db, uint64_t session, uint32_t character)
{
    for (const auto &table : FallEscrowTables) {
        const auto where = FallWhere(table, character);
        Q(db, std::string("DELETE FROM shroud_original_") + table.name + where);
        Q(db, std::string("INSERT INTO shroud_original_") + table.name + " SELECT * FROM " + table.name + where);
    }
    FallManifest(db, session, character);
    for (const auto &table : FallEscrowTables) {
        if (std::string(table.name) == "character_data" || std::string(table.name) == "character_currency") continue;
        Q(db, std::string("DELETE FROM ") + table.name + FallWhere(table, character));
    }
    Q(db, "UPDATE character_currency SET copper=0,silver=0,gold=0,platinum=0,"
        "copper_bank=0,silver_bank=0,gold_bank=0,platinum_bank=0,"
        "copper_cursor=0,silver_cursor=0,gold_cursor=0,platinum_cursor=0 WHERE id=" + S(character));
}

void FallValidateManifest(Database &db, uint64_t session, uint32_t character)
{
    auto manifest = Q(db, "SELECT table_name,row_count FROM spirit_shroud_snapshot_manifest WHERE session_id=" + S(session));
    if (manifest.RowCount() != std::size(FallEscrowTables)) throw std::runtime_error("Fall snapshot manifest missing");
    std::map<std::string, uint64_t> counts;
    for (auto row : manifest) {
        if (!row[0]) throw std::runtime_error("Fall snapshot table missing");
        counts.emplace(row[0], N(row[1]));
    }
    for (const auto &table : FallEscrowTables) {
        auto found = counts.find(table.name);
        if (found == counts.end()) throw std::runtime_error("Fall snapshot manifest row missing");
        auto live = Q(db, std::string("SELECT COUNT(*) FROM shroud_original_") + table.name + FallWhere(table, character));
        if (N(live.begin()[0]) != found->second) throw std::runtime_error("Fall snapshot cardinality changed");
    }
}

void FallRestore(Database &db, uint32_t character)
{
    const auto fields = "race,class,gender,level,level2,points,exp,aa_points,aa_points_spent,aa_exp,"
        "e_percent_to_aa,e_expended_aa_spent,e_aa_effects,cur_hp,mana,endurance,str,sta,cha,dex,int,agi,wis";
    std::string assignments;
    for (const auto &field : Strings::Split(fields, ',')) {
        if (!assignments.empty()) assignments += ",";
        assignments += "c.`" + field + "`=b.`" + field + "`";
    }
    Q(db, "UPDATE character_data c JOIN shroud_original_character_data b ON c.id=b.id SET " + assignments +
        " WHERE c.id=" + S(character));
    for (const auto &table : FallEscrowTables) {
        if (std::string(table.name) == "character_data") continue;
        const auto where = FallWhere(table, character);
        Q(db, std::string("DELETE FROM ") + table.name + where);
        Q(db, std::string("INSERT INTO ") + table.name + " SELECT * FROM shroud_original_" + table.name + where);
        Q(db, std::string("DELETE FROM shroud_original_") + table.name + where);
    }
}

uint16_t FallInstance(Database &db, uint32_t character, uint64_t run)
{
    auto rows = Q(db, "SELECT i.id FROM shared_tasks st "
        "JOIN shared_task_members m ON m.shared_task_id=st.id AND m.character_id=" + S(character) +
        " JOIN shared_task_dynamic_zones z ON z.shared_task_id=st.id "
        "JOIN dynamic_zones dz ON dz.id=z.dynamic_zone_id JOIN instance_list i ON i.id=dz.instance_id "
        "WHERE st.id=" + S(run) + " AND st.task_id=920243 AND i.zone=348 AND i.version=1 "
        "AND st.completion_time IS NULL AND (st.expire_time IS NULL OR st.expire_time>NOW()) "
        "AND (i.never_expires=1 OR i.expire_at>UNIX_TIMESTAMP()) LIMIT 2");
    if (!rows.Success() || rows.RowCount() != 1) return 0;
    const auto id = N(rows.begin()[0]);
    return id > 0 && id <= UINT16_MAX ? uint16_t(id) : 0;
}

} // namespace

bool Client::EnterFallEscrow(uint32_t template_id, uint64_t run, uint32_t instance)
{
    if (m_fall_escrow || IsSpiritShrouded() || !zone || zone->GetZoneID() != 348 ||
        zone->GetInstanceID() != instance || GetSharedTaskId() <= 0 ||
        uint64_t(GetSharedTaskId()) != run || !HasInventorySessionReservation()) return false;
    auto forms = Catalog(template_id, true);
    if (forms.size() != 1) return false;
    const auto &form = forms.front();
    if (form.race != 467 || form.level != 70 || form.verified) return false;
    try {
        auto choice = Q(database, "SELECT template_id FROM fall_shroud_choices WHERE run_id=" + S(run) +
            " AND character_id=" + S(CharacterID()));
        if (choice.RowCount() != 1 || N(choice.begin()[0]) != template_id) return false;
        if (!Save(2) || !SaveAA() || !p_timers.Store(&database)) return false;
        if (!database.TransactionBeginStrict().Success()) return false;
        Q(database, "INSERT INTO spirit_shroud_state(character_id) VALUES(" + S(CharacterID()) +
            ") ON DUPLICATE KEY UPDATE character_id=character_id");
        auto state = Q(database, "SELECT revision FROM spirit_shroud_state WHERE character_id=" + S(CharacterID()) + " FOR UPDATE");
        if (state.RowCount() != 1) throw std::runtime_error("Fall state missing");
        const auto revision = N(state.begin()[0]) + 1;
        Q(database, "INSERT INTO spirit_shroud_sessions(character_id,entry_revision,template_id,content_version,"
            "template_json,entered_at,experience_version,inventory_policy) VALUES(" + S(CharacterID()) + "," +
            S(revision) + "," + S(template_id) + "," + S(form.content_version) + ",'" +
            database.Escape(SpiritShroud::Snapshot(form)) + "'," + S(uint64_t(std::time(nullptr))) + ",0,2)");
        auto session = Q(database, "SELECT LAST_INSERT_ID()");
        const auto session_id = N(session.begin()[0]);
        FallSnapshot(database, session_id, CharacterID());
        Q(database, "UPDATE spirit_shroud_state SET template_id=" + S(template_id) +
            ",active_session_id=" + S(session_id) + ",revision=revision+1 WHERE character_id=" + S(CharacterID()));
        if (!database.TransactionCommitStrict().Success()) throw std::runtime_error("Fall entry commit uncertain");
        m_spirit_shroud_session_id = session_id;
        m_fall_escrow = true;
        m_fall_shrouded = true;
        m_fall_run = run;
        m_fall_instance = instance;
        // The full snapshot removed the character's skills/spells; seed the form's
        // class kit before the reload so EnterNativeShroud's in-memory munge and the
        // database agree.
        Q(database, "INSERT INTO character_skills(id,skill_id,value) SELECT " + S(CharacterID()) +
            ",skill_id,skill_value FROM fall_shroud_skills WHERE template_id=" + S(template_id));
        Q(database, "INSERT INTO character_spells(id,slot_id,spell_id) SELECT " + S(CharacterID()) +
            ",slot_id,spell_id FROM spirit_shroud_spells WHERE template_id=" + S(template_id));
        EnterNativeShroud(template_id, true);
        return true;
    } catch (const std::exception &error) {
        try { database.TransactionRollbackStrict(); } catch (...) {}
        m_fall_escrow = false;
        m_fall_shrouded = false;
        m_spirit_shroud_session_id = 0;
        LogError("Fall escrow entry refused for [{}]: [{}]", GetCleanName(), error.what());
        return false;
    }
}

bool Client::RestoreFallEscrow(bool send_updates)
{
    if (!m_fall_escrow || !m_spirit_shroud_session_id) return false;
    try {
        if (!database.TransactionBeginStrict().Success()) return false;
        auto session = Q(database, "SELECT entry_revision,template_id,phase,inventory_policy FROM spirit_shroud_sessions "
            "WHERE id=" + S(m_spirit_shroud_session_id) + " AND character_id=" + S(CharacterID()) + " FOR UPDATE");
        if (session.RowCount() != 1 || std::string(session.begin()[2] ? session.begin()[2] : "") != "active" ||
            N(session.begin()[3]) != 2) throw std::runtime_error("Fall session changed");
        auto state = Q(database, "SELECT revision,active_session_id FROM spirit_shroud_state WHERE character_id=" + S(CharacterID()) + " FOR UPDATE");
        if (state.RowCount() != 1) throw std::runtime_error("Fall state missing");
        if (N(state.begin()[0]) != N(session.begin()[0]) ||
            !state.begin()[1] || N(state.begin()[1]) != m_spirit_shroud_session_id)
            throw std::runtime_error("Fall state/session revision changed");
        FallValidateManifest(database, m_spirit_shroud_session_id, CharacterID());
        FallRestore(database, CharacterID());
        Q(database, "UPDATE spirit_shroud_sessions SET phase='restored',restored_at=" + S(uint64_t(std::time(nullptr))) +
            " WHERE id=" + S(m_spirit_shroud_session_id) + " AND phase='active'");
        Q(database, "UPDATE spirit_shroud_state SET template_id=0,active_session_id=NULL,revision=revision+1 "
            "WHERE character_id=" + S(CharacterID()));
        Q(database, "DELETE FROM spirit_shroud_snapshot_manifest WHERE session_id=" + S(m_spirit_shroud_session_id));
        if (!database.TransactionCommitStrict().Success()) throw std::runtime_error("Fall restore commit uncertain");
        // Keep the save guard active through MovePC; the destination zone's
        // LoadSpiritShroudState resets m_fall_escrow after reading state=0.
        m_fall_shrouded = false;
        m_spirit_shroud_session_id = 0;
        m_spirit_shroud_template = 0;
        m_spirit_shroud_definition.reset();
        m_spirit_shroud_aa_ranks.clear();
        m_shrouded = false;
        m_shroud_saved_valid = false;
        if (send_updates) Message(Chat::Yellow, "The form fades; your possessions return.");
        MovePC(362, 0, 719.0f, -1031.0f, 83.75f, 214.0f, 0, ZoneSolicited);
        return true;
    } catch (const std::exception &error) {
        try { database.TransactionRollbackStrict(); } catch (...) {}
        LogError("Fall escrow restore refused for [{}]: [{}]", GetCleanName(), error.what());
        return false;
    }
}

bool Client::HasFallOfIllsalinProfile(uint64_t run, uint32_t instance)
{
    return zone && zone->GetZoneID() == 348 && zone->GetInstanceID() == instance &&
        GetSharedTaskId() > 0 && uint64_t(GetSharedTaskId()) == run && IsTaskActive(920243);
}

bool Client::EnterFallOfIllsalin(NPC &stillpool)
{
    if (IsSpiritShrouded() || m_fall_escrow || !zone || zone->GetZoneID() != 362 || zone->GetInstanceID() ||
        GetSharedTaskId() <= 0 || stillpool.GetNPCTypeID() != 362104 || stillpool.GetSpawnPointID() != 102601 ||
        entity_list.GetNPCByID(stillpool.GetID()) != &stillpool) return false;
    try {
        const auto run = uint64_t(GetSharedTaskId());
        auto choice = Q(database, "SELECT template_id FROM fall_shroud_choices WHERE run_id=" + S(run) +
            " AND character_id=" + S(CharacterID()));
        if (choice.RowCount() != 1) return false;
        const auto instance = FallInstance(database, CharacterID(), run);
        if (!instance) return false;
        m_fall_run = run;
        m_fall_instance = instance;
        MovePC(348, instance, 8.0f, 0.0f, -20.0f, 0.0f, 0, ZoneSolicited);
        return true;
    } catch (const std::exception &error) {
        LogError("Fall entry refused for [{}]: [{}]", GetCleanName(), error.what());
        return false;
    }
}

bool Client::ApplyFallEscrow(uint64_t run, uint32_t template_id)
{
    if (!zone || zone->GetZoneID() != 348 || !zone->GetInstanceID() ||
        uint64_t(GetSharedTaskId()) != run) return false;
    m_fall_instance = zone->GetInstanceID();
    return EnterFallEscrow(template_id, run, m_fall_instance);
}

bool Client::ExitFallOfIllsalin(uint64_t run, uint32_t instance, NPC &draygun)
{
    if (!HasFallOfIllsalinProfile(run, instance) || draygun.GetNPCTypeID() != 348005 ||
        draygun.GetSpawnPointID() != 260192) return false;
    if (!RestoreFallEscrow(true)) return false;
    UpdateTaskActivity(920243, 4, 1);
    return true;
}

bool Client::RegisterFallOfIllsalinCommanderCorpse(uint64_t run, uint32_t instance, Corpse &corpse)
{
    return HasFallOfIllsalinProfile(run, instance) && corpse.IsNPCCorpse() &&
        entity_list.GetCorpseByID(corpse.GetID()) == &corpse;
}
