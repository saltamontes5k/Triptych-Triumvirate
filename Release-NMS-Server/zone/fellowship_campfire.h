#ifndef EQEMU_ZONE_FELLOWSHIP_CAMPFIRE_H
#define EQEMU_ZONE_FELLOWSHIP_CAMPFIRE_H
class Client;
namespace Fellowship { namespace Campsites { struct Definition; } }
const Fellowship::Campsites::Definition* GetFellowshipCampsiteEffect(const Client& client);
void InvalidateFellowshipCampsites();
void SetFellowshipCampsiteRadius(float radius);
// Reconciles durable campfires every five seconds, including empty zones.
void ProcessFellowshipCampfires();
void ClearFellowshipCampfires();
#endif
