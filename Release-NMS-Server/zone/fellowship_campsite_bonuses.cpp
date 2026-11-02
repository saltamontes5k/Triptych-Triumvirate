#include "fellowship_campsite_bonuses.h"
#include "fellowship_campfire.h"
#include "client.h"
#include "npc.h"
#include "../common/spdat.h"
#include <algorithm>
#include <cstring>
#include <map>
using Fellowship::Campsites::Definition;
using Fellowship::Campsites::Effect;
int64_t MergeFellowshipCampsiteFocus(int64_t existing, int32_t campsite) {
 // A missing aura cannot erase negative focus. Existing negative debuffs also
 // take priority over an active beneficial campsite focus.
 return campsite > 0 && existing >= 0 ? std::max<int64_t>(existing,campsite) : existing;
}
int32_t GetFellowshipCampsiteFocus(const Client& client, focusType type, uint16_t spell_id) {
 const auto* d = GetFellowshipCampsiteEffect(client);
 if (!d || !IsValidSpell(spell_id)) return 0;
 const bool beneficial = IsBeneficialSpell(spell_id);
 bool matching = false;
 switch (d->effect) {
 case Effect::SpellDamagePercent: matching = type == focusImprovedDamage; break;
 case Effect::HealingPercent: matching = type == focusImprovedHeal; break;
 case Effect::ManaCostPercent: case Effect::BeneficialManaCostPercent: matching = type == focusManaCost; break;
 case Effect::CastTimePercent: matching = type == focusSpellHaste; break;
 case Effect::BeneficialCastTimePercent: matching = type == focusSpellHaste && spells[spell_id].buff_duration > 0; break;
 case Effect::DurationPercent: case Effect::BeneficialDurationPercent: matching = type == focusSpellDuration; break;
 default: break;
 }
 return matching ? Fellowship::Campsites::FocusMaximum(*d, GetSpellLevel(spell_id, client.GetClass()), beneficial) : 0;
}
namespace {
constexpr const char* AuraCaster = "Fellowship_Campsite_Aura";
struct AppearanceState {
 const Client* client{}; uint32_t entity{}, definition{}; bool illusion_owned{};
 AppearanceStruct before{}, applied{}; uint16_t race{}; uint8_t gender{}, texture{}, helm{};
};
std::map<uint32_t, AppearanceState> appearances;
bool NormalIllusion(Client& c) {
 for (int i = 0; i < c.GetMaxTotalSlots(); ++i) if (IsValidSpell(c.GetBuffs()[i].spellid) && (IsEffectInSpell(c.GetBuffs()[i].spellid, SE_Illusion) || IsEffectInSpell(c.GetBuffs()[i].spellid, SE_IllusionCopy))) return true;
 return false;
}
AppearanceStruct Appearance(Client& c) {
 AppearanceStruct a;
 a.race_id = c.GetRace(); a.gender_id = c.GetGender(); a.texture = c.GetTexture(); a.helmet_texture = c.GetHelmTexture(); a.size = c.GetSize();
 a.beard=c.GetBeard();a.beard_color=c.GetBeardColor();a.eye_color_one=c.GetEyeColor1();a.eye_color_two=c.GetEyeColor2();a.face=c.GetLuclinFace();a.hair=c.GetHairStyle();a.hair_color=c.GetHairColor();
 a.drakkin_heritage=c.GetDrakkinHeritage();a.drakkin_tattoo=c.GetDrakkinTattoo();a.drakkin_details=c.GetDrakkinDetails();
 return a;
}
void RestoreAppearance(Client& client,const AppearanceState& a) {
 auto restored=a.before;
 const auto current=Appearance(client);
 // Preserve shrink/grow and cosmetic changes made after the camp illusion.
 // Only fields still equal to our applied appearance are reverted.
#define PRESERVE(field) if(current.field!=a.applied.field)restored.field=current.field
 PRESERVE(size);PRESERVE(texture);PRESERVE(helmet_texture);PRESERVE(beard);PRESERVE(beard_color);
 PRESERVE(eye_color_one);PRESERVE(eye_color_two);PRESERVE(face);PRESERVE(hair);PRESERVE(hair_color);
 PRESERVE(drakkin_heritage);PRESERVE(drakkin_tattoo);PRESERVE(drakkin_details);
#undef PRESERVE
 client.SendIllusionPacket(restored);
 for(int slot=EQ::textures::textureBegin;slot<=EQ::textures::LastTintableTexture;++slot)client.SendWearChange(slot);
}
bool OwnedAppearance(const Client& c, const AppearanceState& a) {
 return a.illusion_owned && c.GetRace()==a.race && c.GetGender()==a.gender;
}
bool ValidSupport(uint16_t spell, bool levitate) {
 if (!IsValidSpell(spell)) return false;
 bool see=false, water=false, third=false, poison=!levitate;
 for (int i=0;i<EFFECT_COUNT;++i) {
  const auto e=spells[spell].effect_id[i], v=spells[spell].base_value[i];
  if (e==SE_Blank || !v) continue;
  if (e==SE_SeeInvis && v==1) see=true;
  else if (e==SE_WaterBreathing && v==(levitate?2:1)) water=true;
  else if (e==(levitate?SE_Levitate:SE_UltraVision) && v==(levitate?2:1)) third=true;
  else if (levitate && e==SE_ResistPoison && v==20) poison=true;
  else return false;
 }
 return see && water && third && poison;
}
uint64_t TemplateSignature(uint16_t spell) {
 uint64_t hash=UINT64_C(14695981039346656037);
 const auto word=[&](uint32_t value){for(unsigned b=0;b<4;++b){hash^=uint8_t(value>>(b*8));hash*=UINT64_C(1099511628211);}};
 for(int i=0;i<EFFECT_COUNT;++i) {
  word(spells[spell].effect_id[i]);word(spells[spell].base_value[i]);word(spells[spell].limit_value[i]);word(spells[spell].max_value[i]);word(spells[spell].formula[i]);
 }
 word(spells[spell].buff_duration_formula);word(spells[spell].buff_duration);word(spells[spell].short_buff_box);
 return hash;
}
bool NativeTemplateMatches(const Fellowship::Campsites::NativeBuff& buff) {
 return IsValidSpell(buff.spell_id) && TemplateSignature(buff.spell_id)==buff.template_signature;
}
void LeasedBuff(Client& client, NPC* source, std::optional<Fellowship::Campsites::NativeBuff> desired) {
 bool changed=false;
 for (int i=0;i<client.GetMaxTotalSlots();++i) {
  auto& b=client.GetBuffs()[i];
  if (IsFellowshipCampsiteAuraBuff(b.spellid,b.caster_name,sizeof(b.caster_name))) {
   if (!desired || b.spellid!=desired->spell_id || b.casterlevel!=desired->caster_level || !source) { client.BuffFadeBySlot(i);changed=true; }
   else { b.ticsremaining=2;client.SendBuffDurationPacket(b,i);b.UpdateClient=false; }
  }
 }
 if(desired && source && !client.FindBuff(desired->spell_id)) {
  bool safe=true;
  // disable_buff_overwrite alone still permits AddBuff to reuse an occupied
  // overwrite slot. Preflight every ordinary buff and refuse both blocks and
  // overwrites, preserving all spell ownership and negative effects.
  for(int i=0;i<client.GetMaxTotalSlots();++i) {
   const auto& existing=client.GetBuffs()[i];
   if(IsValidSpell(existing.spellid) && client.CheckStackConflict(existing.spellid,existing.casterlevel,desired->spell_id,desired->caster_level,nullptr,source,i)!=0){safe=false;break;}
  }
  if(safe && source->SpellOnTarget(desired->spell_id,&client,0,false,0,false,desired->caster_level,2,true)) {
   for(int i=0;i<client.GetMaxTotalSlots();++i) {
    auto& b=client.GetBuffs()[i];
    if(b.spellid==desired->spell_id && b.casterid==source->GetID()) {std::strcpy(b.caster_name,AuraCaster);b.persistant_buff=false;client.SendBuffDurationPacket(b,i);b.UpdateClient=false;changed=true;}
   }
  }
 }
 if(changed) {
  // The normal spell-bonus path is the only source of native projected stats.
  // Send the resulting resources after addition and removal alike.
  client.CalcBonuses(); // Includes CalcMaxHP, CalcMaxMana and CalcMaxEndurance.
  client.SendHPUpdate();client.SendManaUpdate();
 }
}
}
bool IsFellowshipCampsiteAuraBuff(uint16_t spell,const char* caster,size_t bound) {
 if(!((spell>=7354 && spell<=7371) || (spell>=7607 && spell<=7617) || spell==3660 || spell==457) || !caster)return false;
 size_t length=0;while(length<bound && caster[length])++length;
 return length==std::strlen(AuraCaster) && std::memcmp(caster,AuraCaster,length)==0;
}
void ReconcileFellowshipCampsiteAppearance(Client& client, NPC* source, const Definition* d) {
 auto& a=appearances[client.CharacterID()];
 if(a.client!=&client || a.entity!=client.GetID()) { a={};a.client=&client;a.entity=client.GetID(); }
 const bool normal=NormalIllusion(client);
 if (!d || d->effect!=Effect::Illusion || !source || normal || client.GetIllusionBlock()) {
  if (OwnedAppearance(client,a) && !normal) RestoreAppearance(client,a);
  a.illusion_owned=false;
 } else if (!OwnedAppearance(client,a) || a.definition!=d->id) {
  if (OwnedAppearance(client,a)) RestoreAppearance(client,a);
  const auto spell=d->appearance_template_spell_id;
  if (IsValidSpell(spell) && spells[spell].effect_id[0]==SE_Illusion && spells[spell].base_value[0]>0) {
   a.before=Appearance(client);
   client.ApplySpellEffectIllusion(spell,&client,-1,spells[spell].base_value[0],spells[spell].limit_value[0],spells[spell].max_value[0]);
   a.applied=Appearance(client);a.illusion_owned=true;a.definition=d->id;a.race=client.GetRace();a.gender=client.GetGender();a.texture=client.GetTexture();a.helm=client.GetHelmTexture();
  }
 }
 std::optional<Fellowship::Campsites::NativeBuff> buff;
 if(d && source) {
  auto native=Fellowship::Campsites::NativeBuffFor(*d);
  if(native && NativeTemplateMatches(*native))buff=native;
  else if(d->effect==Effect::Faerune && ValidSupport(7616,false))buff=Fellowship::Campsites::NativeBuff{7616,1,0,0};
  else if(d->effect==Effect::DeadManFloating && ValidSupport(7617,true))buff=Fellowship::Campsites::NativeBuff{7617,1,0,0};
 }
 LeasedBuff(client,source,buff);
}
bool FellowshipCampsiteNativeBuffSupported(const Definition& d) {
 if(const auto native=Fellowship::Campsites::NativeBuffFor(d))return NativeTemplateMatches(*native);
 return Fellowship::Campsites::Category(d)!=3 && Fellowship::Campsites::Category(d)!=4 && Fellowship::Campsites::Category(d)!=5 && !(d.effect>=Effect::HitPoints && d.effect<=Effect::DamageShield);
}
void ClearFellowshipCampsiteAppearanceState() { appearances.clear(); }
