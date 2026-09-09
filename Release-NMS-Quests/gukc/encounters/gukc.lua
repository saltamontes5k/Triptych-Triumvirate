-- Encounter: LDoN Raid: Deepest Guk: The Rescue
-- Zone: gukc / (version 50)
--
-- Cast (pre-placed in the instance by DB spawn2):
--   #Bitle_Cogswin     (239299) - raid organizer inside the instance
--   Ritual_Guardian    (239292 / 239295 / 239297) - one per wing (vine / crevice / aqueducts)
--   #Lich_Rtrangi      (239289) - final boss
--   prisoners          (239291) - freed flavor
--   WaveTxt A/B/C      (239298 / 239294 / 239288) - per-wing wave emotes
--
-- Flow (doc): Bitle splits the raid into three wings to destroy the three Ritual
-- Guardians, then Lich Rtrangi is slain. Guardians may be killed in any order; once
-- all three are down the shroud weakens and Rtrangi becomes the sole objective.
-- Wing teleports are intentionally omitted (no mapped coordinates); groups clear their
-- wing's trash naturally. Reward: Bidip's Ornate Chest spawned at Rtrangi's corpse.

local guardian_count = 0;
local guardians_down = false;
local rtrangi_down = false;

function Bitle_Say(e)
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Bitle Cogswin says, 'Ah yes you must be the group of volunteers sent by the wayfaring brotherhood. We have a very serious situation here and little time to resolve it. The prisoners have been placed in three separate rooms and each is guarded by Lich Rtrangi's minions. Split into three groups, one for the [vine room], the [crevice room], and the [aqueducts], and I will tell you how to proceed. Beware - once the ritual begins Rtrangi is alerted.'")
  elseif e.message:findi("vine room") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Bitle Cogswin says, 'The vine room lies to the west. Destroy the Ritual Guardian there and keep the summoners away from Rtrangi!'")
    eq.zone_emote(MT.Yellow, "The vines writhe and lash as the Witnesses of Hate begin their rite in the vine room.")
  elseif e.message:findi("crevice room") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Bitle Cogswin says, 'The crevice room lies to the east. Destroy the Ritual Guardian there and keep the summoners away from Rtrangi!'")
    eq.zone_emote(MT.Yellow, "A tremor runs through the stone as the rite in the crevice room begins.")
  elseif e.message:findi("aqueducts") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Bitle Cogswin says, 'The aqueducts lie to the south - the largest area, so bring the most people. Destroy the Ritual Guardian there and keep the summoners away from Rtrangi!'")
    eq.zone_emote(MT.Yellow, "Water churns and rushes as the rite in the aqueducts begins.")
  end
end

function Guardian_Death(e)
  guardian_count = guardian_count + 1;
  if guardian_count == 3 and not guardians_down then
    guardians_down = true;
    eq.zone_emote(MT.Yellow, "Your victory has weakened a shroud of magic cloaking the dungeon's treasure.")
    eq.zone_emote(MT.Yellow, "Bitle Cogswin shouts, 'Now you have done it. The ritual has failed now all that is left is to destroy Rtrangi so that he can never try this again.'")
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "Lich Rtrangi's ritual has failed! Head for him and end this.")
  end
end

function Rtrangi_Death(e)
  rtrangi_down = true;
  eq.zone_emote(MT.Yellow, "The First Witness' servant is destroyed. The curse that gripped Deepest Guk loosens its hold.")
  eq.zone_emote(MT.Yellow, "Your victory has shattered the shroud of magic surrounding the dungeon's treasure")

  local el = eq.get_entity_list()
  -- Reward chest at the lich's remains
  eq.spawn2(259158, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Bidip`s Ornate Chest

  local dz = eq.get_expedition()
  if dz and dz.valid then
    dz:AddReplayLockout(eq.seconds("4d12h"))
      eq.zone_emote(MT.Yellow, "The Wayfarers take note of your victory.")
      local __cl = eq.get_entity_list():GetClientList()
      if __cl then
        for _, __c in __cl.entries do
          __c:UpdateLDoNPoints(1, 5)
        end
      end
  end
end

function event_encounter_load(e)
  eq.register_npc_event('gukc', Event.say, 239299, Bitle_Say);
  eq.register_npc_event('gukc', Event.death_complete, 239292, Guardian_Death);
  eq.register_npc_event('gukc', Event.death_complete, 239295, Guardian_Death);
  eq.register_npc_event('gukc', Event.death_complete, 239297, Guardian_Death);
  eq.register_npc_event('gukc', Event.death_complete, 239289, Rtrangi_Death);
end
