#include "campsite_catalogue.h"
namespace Fellowship { namespace Campsites {
namespace {
const Definition definitions[] = {
#include "campsite_catalogue_data.inc"
};
}
std::optional<NativeBuff> NativeBuffFor(const Definition& d) {
 uint16_t spell=0;unsigned coefficient=0,offset=0,slot=0,maximum_level=12;
 switch(d.effect) {
 case Effect::CriticalHitChance:spell=7354;coefficient=6;maximum_level=8;break;
 case Effect::DoubleAttackChance:spell=7355;coefficient=1;maximum_level=8;break;
 case Effect::RangedHitChance:spell=7356;coefficient=1;maximum_level=8;break;
 case Effect::DodgeChance:spell=7357;coefficient=3;maximum_level=8;break;
 case Effect::ParryChance:spell=7358;coefficient=2;maximum_level=8;break;
 case Effect::Strength:spell=7359;coefficient=15;break;
 case Effect::Stamina:spell=7360;coefficient=15;break;
 case Effect::Dexterity:spell=7361;coefficient=15;break;
 case Effect::Agility:spell=7362;coefficient=15;break;
 case Effect::Intelligence:spell=7363;coefficient=7;slot=2;break;
 case Effect::Wisdom:spell=7364;coefficient=7;slot=3;break;
 case Effect::Charisma:spell=7365;coefficient=15;break;
 case Effect::FireResist:spell=7366;coefficient=15;break;
 case Effect::ColdResist:spell=7367;coefficient=15;break;
 case Effect::MagicResist:spell=7368;coefficient=15;break;
 case Effect::PoisonResist:spell=7369;coefficient=15;break;
 case Effect::DiseaseResist:spell=7370;coefficient=15;break;
 case Effect::CorruptionResist:spell=7371;coefficient=3;break;
 case Effect::HitPoints:spell=7607;coefficient=75;slot=11;maximum_level=22;break;
 case Effect::HitPointRegen:spell=7608;coefficient=6;slot=11;break;
 case Effect::Mana:spell=7609;coefficient=75;slot=11;maximum_level=22;break;
 case Effect::ManaRegen:spell=7610;coefficient=2;slot=11;break;
 case Effect::Endurance:spell=7611;coefficient=75;slot=11;maximum_level=22;break;
 case Effect::EnduranceRegen:spell=7612;coefficient=2;slot=11;break;
 case Effect::Haste:spell=7613;coefficient=3;break;
 case Effect::Attack:spell=7614;coefficient=15;slot=11;break;
 case Effect::DamageShield:spell=7615;coefficient=5;offset=5;slot=11;break;
 default:return std::nullopt;
 }
 if(!d.implemented || d.amount<=static_cast<int32_t>(offset) || (d.amount-offset)%coefficient)return std::nullopt;
 const unsigned level=(d.amount-offset)/coefficient;
 if(!level || level>maximum_level)return std::nullopt;
 static const struct {uint16_t spell;uint64_t signature;} signatures[]={
#include "campsite_native_templates.inc"
 };
 for(const auto& signature:signatures)if(signature.spell==spell)return NativeBuff{spell,static_cast<uint8_t>(level),static_cast<uint8_t>(slot),signature.signature};
 return std::nullopt;
}
const Definition* All() { return definitions; }
size_t Count() { return sizeof(definitions) / sizeof(definitions[0]); }
const Definition* Lookup(uint32_t id) {
 for (const auto& d : definitions) if (d.id == id) return &d;
 return nullptr;
}
std::array<Material, 2> RequiredMaterials(const Definition& d) {
 return {{{d.kit_item_id, d.kit_item_id ? 1u : 0u}, {d.lumber_item_id, d.lumber_item_id ? 1u : 0u}}};
}
bool IsFocus(Effect e) { return e >= Effect::SpellDamagePercent && e <= Effect::BeneficialDurationPercent; }
uint32_t Category(const Definition& d) {
 if (d.effect==Effect::None) return 1;
 if (IsFocus(d.effect)) return 2;
 if (d.effect>=Effect::CriticalHitChance && d.effect<=Effect::ParryChance) return 3;
 if (d.effect>=Effect::Strength && d.effect<=Effect::Charisma) return 4;
 if (d.effect>=Effect::MagicResist && d.effect<=Effect::CorruptionResist) return 5;
 if (d.effect==Effect::Illusion) return 6;
 return 7;
}
int32_t FocusMaximum(const Definition& d, uint32_t level, bool beneficial) {
 if (!d.implemented || !IsFocus(d.effect) || (d.spell_level_max && level > d.spell_level_max)) return 0;
 if ((d.effect == Effect::BeneficialManaCostPercent || d.effect == Effect::BeneficialCastTimePercent || d.effect == Effect::BeneficialDurationPercent) && !beneficial) return 0;
 return d.amount;
}
} }
