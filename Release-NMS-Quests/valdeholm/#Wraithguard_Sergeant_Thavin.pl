# Wraithguard Sergeant Thavin - Valdeholm (Frostcrypt raid entry)
# Moves a player into the instanced Frostcrypt for the First (v1) or Second (v2) raid.
# npc: 401012

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail, $name. Frostcrypt is no place for the timid. If Fergarin or Commander Haesgrin sent you, speak up and we will open the way.");
  }

  if ($text=~/fergarin/i) {
    quest::say("Then the First Frostcrypt is yours to take. Steel yourself, $name.");
    $client->MovePCDynamicZone(402, 1);
  }

  if ($text=~/haesgrin/i) {
    quest::say("So Haesgrin sends you into the Sleepless Guard. May the gods watch over you, $name.");
    $client->MovePCDynamicZone(402, 2);
  }
}
