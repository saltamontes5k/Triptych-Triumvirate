#ifndef EQEMU_CHARACTER_DYNAMIC_AA_TIMERS_REPOSITORY_H
#define EQEMU_CHARACTER_DYNAMIC_AA_TIMERS_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_character_dynamic_aa_timers_repository.h"

class CharacterDynamicAaTimersRepository: public BaseCharacterDynamicAaTimersRepository {
public:

    // Get all AA timers for a specific character
    static std::vector<CharacterDynamicAaTimers> GetByCharacterId(Database& db, int character_id)
    {
        return GetWhere(db, fmt::format("character_id = {}", character_id));
    }

    // Delete all AA timers for a character
    static int DeleteByCharacterId(Database& db, int character_id)
    {
        return DeleteWhere(db, fmt::format("character_id = {}", character_id));
    }

    // Find next available timer slot for a character within AA timer bounds
    static int FindAvailableTimerSlot(Database& db, int character_id, int timer_start, int timer_end)
    {
        auto e = GetByCharacterId(db, character_id);
        std::set<int> used_timers;

        for (const auto& entry : e) {
            used_timers.insert(entry.timer_id);
        }

        for (int timer_id = timer_start; timer_id <= timer_end; ++timer_id) {
            if (used_timers.find(timer_id) == used_timers.end()) {
                return timer_id;
            }
        }
        return 0; // No available slots
    }

    // Set AA timer with automatic slot assignment
    static int SetAATimer(Database& db, int character_id, int aa_id, int timer_start, int timer_end)
    {
        int timer_id = FindAvailableTimerSlot(db, character_id, timer_start, timer_end);
        if (timer_id == 0) {
            return 0;
        }

        auto entry = NewEntity();
        entry.character_id = character_id;
        entry.aa_id = aa_id;
        entry.timer_id = timer_id;

        auto result = InsertOne(db, entry);
        return result.character_id != 0 ? timer_id : 0;
    }
};

#endif //EQEMU_CHARACTER_DYNAMIC_AA_TIMERS_REPOSITORY_H