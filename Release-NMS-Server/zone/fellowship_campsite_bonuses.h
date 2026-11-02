#ifndef EQEMU_ZONE_FELLOWSHIP_CAMPSITE_BONUSES_H
#define EQEMU_ZONE_FELLOWSHIP_CAMPSITE_BONUSES_H
#include "common.h"
#include "../common/fellowship/campsite_catalogue.h"
class Client;
class NPC;
bool FellowshipCampsiteNativeBuffSupported(const Fellowship::Campsites::Definition& definition);
int64_t MergeFellowshipCampsiteFocus(int64_t existing, int32_t campsite);
int32_t GetFellowshipCampsiteFocus(const Client& client, focusType type, uint16_t spell_id);
bool IsFellowshipCampsiteAuraBuff(uint16_t spell_id, const char* caster, size_t bound);
void ReconcileFellowshipCampsiteAppearance(Client& client, NPC* source, const Fellowship::Campsites::Definition* definition);
void ClearFellowshipCampsiteAppearanceState();
#endif
