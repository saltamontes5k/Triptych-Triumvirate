# Vergalid - Vergalid Mines (TSS instanced raid finale, Vergalid's End)
# npc: 600144   dz template: 6007
# The beast at the heart of the mines. Its life force is fed by the six Stone Protectors.

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
