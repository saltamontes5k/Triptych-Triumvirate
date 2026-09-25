# Vergalid - Vergalid Mines (TSS instanced raid finale, Vergalid's End)
# npc: 600144   dz template: 6007
# The beast at the heart of the mines. Its life force is fed by the six Stone Protectors.
#
# This file is also the ZONE script for vergalid (the zone script name
# "vergalid.pl" resolves to this file on Windows): sub EVENT_CLICKDOOR below
# guards the stone statue at the Shrine of Zek (doors table doorid 4,
# OBJ_VM_DOORA at -1438.81, 879.28, -394.38). Clicking it while carrying a
# Flawless Indicolite Shard (87246) leads down to the Inner Vergalid /
# Ancient Ruins (zone_points 1625/3449: -1291, 375, -1070, heading 282).

sub EVENT_CLICKDOOR {
  if ($doorid == 4) {
    if (plugin::check_hasitem($client, 87246)) {
      $client->Message(4, "The Flawless Indicolite Shard flares to life in your grasp. The stone statue grinds aside, and a cold draft rises from the deep halls of the Ancient Ruins.");
      quest::movepc(404, -1291, 375, -1070, 282);
    }
    else {
      $client->Message(13, "The stone statue stands silent. Its sealed gate does not answer to you.");
    }
    return 1;
  }
}

sub EVENT_SPAWN {
  quest::setnexthpevent(60);
}

sub EVENT_AGGRO {
  quest::shout("SSSO. The little crusaders come at lassst. I have eaten better than you.");
}

sub EVENT_HP {
  if ($hpevent == 60) {
    quest::shout("My children! Come tear them apart!");
    quest::emote("convulses, and spawn of its corrupted blood claw up from the stone.");
    for (my $i = 0; $i < 2; $i++) {
      my $x = $npc->GetX() + int(60 * cos($i * 3.14159));
      my $y = $npc->GetY() + int(60 * sin($i * 3.14159));
      quest::spawn2(404069, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(30);
  }
  elsif ($hpevent == 30) {
    quest::shout("You cannot kill what the mine itself sustains!");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Vergalid shudders, and for the first time in an age, the mines fall silent.");
}
