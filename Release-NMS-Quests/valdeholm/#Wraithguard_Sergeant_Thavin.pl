# Wraithguard Sergeant Thavin - Valdeholm (Frostcrypt raid entry)
# Moves a player into the instanced Frostcrypt for the First (v1) or Second (v2) raid.
# Also receives the keepsakes returned by the freed spirits of Frostcrypt (600733-600736).
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

sub EVENT_ITEM {
  # The restless shades of Frostcrypt send grave-goods home through us.
  # Keepsakes: 28688 Thontik's Blade, 28691 Aethmir's Pendent of Zek,
  #            28692 Skalmarg's Torn Leather War Banner, 28689 Aerigin's Cloak
  my $kept = 0;
  foreach my $iid (28688, 28691, 28692, 28689) {
    if (plugin::check_handin(\%itemcount, $iid => 1)) {
      $kept++;
      quest::say("So one of the freed spirits sent this home. It will rest with its owner's kin. The Wraithguard thank you, $name.");
      quest::faction(1104, 50); # Wraithguard
    quest::faction(1105, 50); # Wraithguard Leadership
    }
  }
  plugin::return_items(\%itemcount);
}
