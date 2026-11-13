#pragma once
#include <array>
#include <cstdint>

namespace SpiritShroud {
// Storage order is independent of the counted and compact RoF2 wire layouts.
enum NativeStat : unsigned {
 HP, Mana, Endurance, HPRegen, ManaRegenSitting, ManaRegenStanding,
 EnduranceRegen, Cold, Fire, Magic, Disease, Poison, AdditionalResist,
 Corruption, AC, Attack, UnarmedDamage, UnarmedDelay, NativeStatCount
};

// RoF2 counted PlayerProfile: twenty dwords following the inventory slot mask.
// The compact transformation profile carries the same block at offset 0x4fa4.
// Preserve the two unidentified floats as the existing encoder's 0.0f defaults.
inline std::array<uint32_t,20> NativeStatTail(const uint32_t* values)
{
 return {{values[HP],values[Endurance],values[Mana],
          values[Cold],values[Fire],values[Magic],values[Disease],
          values[Poison],values[AdditionalResist],values[Corruption],0,0,
          values[HPRegen],values[ManaRegenSitting],values[ManaRegenStanding],
          values[EnduranceRegen],values[AC],values[Attack],
          values[UnarmedDamage],values[UnarmedDelay]}};
}
}
