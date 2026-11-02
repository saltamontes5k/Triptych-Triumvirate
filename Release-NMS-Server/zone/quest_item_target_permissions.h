#ifndef EQEMU_QUEST_ITEM_TARGET_PERMISSIONS_H
#define EQEMU_QUEST_ITEM_TARGET_PERMISSIONS_H
#include <algorithm>
#include <array>
#include <cstdint>

namespace QuestItemTargetPermissions {
struct Context {
    uint32_t spell_id = 0;
    uint32_t zone_id = 0;
    uint32_t item_id = 0;
    uint32_t item_click_spell_id = 0;
    uint32_t target_npc_type_id = 0;
    uint32_t target_race = 0;
    bool authentic_item_cast = false;
    bool expected_spell_shape = false;
    bool correct_task_activity_active = false;
    bool target_is_npc = false;
    bool target_is_owned = false;
    bool target_attackable = false;
    float target_hp_ratio = 0;
};
// Generated from the same reviewed May2013 Shards quest roster as the Lua module.
inline constexpr std::array<uint32_t, 64> SoulTargets = { 752066, 752067, 752068, 752069, 752070, 752072, 752075, 752078, 752079, 752095, 752103, 752108, 752111, 752112, 752115, 752121, 752122, 752123, 752125, 752128, 752132, 752135, 752139, 752141, 752147, 752148, 752149, 752153, 752155, 752157, 752159, 752161, 752162, 752163, 752166, 752169, 752170, 752172, 752173, 752174, 752175, 752177, 752179, 752181, 752182, 752184, 752186, 752188, 752189, 752193, 752194, 752195, 752198, 752203, 752204, 752206, 752207, 752208, 752209, 752211, 752213, 752217, 752218, 752228 };
inline constexpr std::array<uint32_t, 7> SlashclawCubs = {395078, 395086, 395104, 395106, 395116, 395127, 395130};
// Order matches the four distinct Moorwalker task activities.
inline constexpr std::array<uint32_t, 4> Moorwalkers = {395221,395174,395249,395153};
inline bool Allows(const Context &c) {
    if (!c.authentic_item_cast || !c.expected_spell_shape ||
        !c.correct_task_activity_active ||
        !c.target_is_npc || c.target_is_owned ||
        c.item_click_spell_id != c.spell_id) {
        return false;
    }
    if (c.spell_id == 9255) {
        return c.zone_id == 395 && c.item_id == 85753 && c.target_hp_ratio > 0 &&
            std::find(SlashclawCubs.begin(), SlashclawCubs.end(), c.target_npc_type_id) != SlashclawCubs.end();
    }
    if (c.spell_id == 9181) {
        return c.zone_id == 395 && c.item_id == 85760 && c.target_hp_ratio > 0 &&
            std::find(Moorwalkers.begin(), Moorwalkers.end(), c.target_npc_type_id) != Moorwalkers.end();
    }
    if (c.zone_id != 752) { return false; }
    if (c.spell_id == 33562) {
        return c.item_id == 86076 && c.target_npc_type_id == 752049;
    }
    if (c.spell_id == 33564) {
        return c.item_id == 86086 && c.target_race == 695 &&
            c.target_attackable && c.target_hp_ratio > 0 && c.target_hp_ratio <= 25 &&
            std::find(SoulTargets.begin(), SoulTargets.end(), c.target_npc_type_id) != SoulTargets.end();
    }
    return false;
}
} // namespace QuestItemTargetPermissions
// Retain the existing name for consumers of the earlier Shards-only helper.
namespace ShardsQuestItemTargetPermissions = QuestItemTargetPermissions;
#endif
