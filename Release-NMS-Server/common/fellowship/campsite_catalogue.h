#ifndef EQEMU_FELLOWSHIP_CAMPSITE_CATALOGUE_H
#define EQEMU_FELLOWSHIP_CAMPSITE_CATALOGUE_H
#include <array>
#include <cstddef>
#include <cstdint>
#include <optional>
namespace Fellowship { namespace Campsites {
enum class Effect : uint16_t {
 None, SpellDamagePercent, HealingPercent, ManaCostPercent, BeneficialManaCostPercent,
 CastTimePercent, BeneficialCastTimePercent, DurationPercent, BeneficialDurationPercent,
 Strength, Stamina, Dexterity, Agility, Intelligence, Wisdom, Charisma,
 MagicResist, FireResist, ColdResist, PoisonResist, DiseaseResist, CorruptionResist,
 HitPoints, HitPointRegen, Mana, ManaRegen, Endurance, EnduranceRegen, Haste, Attack, DamageShield,
 Illusion, Faerune, DeadManFloating,
 CriticalHitChance, DoubleAttackChance, RangedHitChance, DodgeChance, ParryChance
};
struct Definition {
 uint32_t id, description_id;
 const char* name;
 uint32_t kit_item_id, lumber_item_id;
 Effect effect;
 int32_t amount;
 uint32_t spell_level_max;
 // Existing real spell used only to recover illusion appearance, never as an
 // invented fellowship spell ID. Ignore unrelated effects on that spell.
 uint32_t appearance_template_spell_id;
 bool implemented;
};
struct Material { uint32_t item_id, count; };
constexpr uint32_t LifetimeSeconds = 3600; // Official 2007 fellowship documentation.
// Explicit emulator policy: primary sources establish proximity, not a radius.
constexpr float DefaultEffectRadius = 100.0f;
struct NativeBuff { uint16_t spell_id; uint8_t caster_level, primary_slot; uint64_t template_signature; };
// Numeric/melee effects use real matched Standard buffs so both client and
// server compute their bonuses from the same spell and effective caster level.
std::optional<NativeBuff> NativeBuffFor(const Definition& definition);
const Definition* All();
size_t Count();
const Definition* Lookup(uint32_t id);
std::array<Material, 2> RequiredMaterials(const Definition& definition);
bool IsFocus(Effect effect);
// Matching client Resources/campsitecategories.txt IDs1..7.
uint32_t Category(const Definition& definition);
// Descriptions provide maximum values, not live random focus distribution.
// Integration uses the described maximum as an explicit deterministic policy.
int32_t FocusMaximum(const Definition& definition, uint32_t spell_level, bool beneficial);
} }
#endif
