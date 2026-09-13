# King Odeen - Valdeholm (TSS instanced raid encounter, "Speak with the King")
# npc: 600120   adds: 600121 Hethgar, 600122 Faelig, 600123 Thair,
#              600124 Clanghor, 600125 a_Royal_Guardsman
# dz template: 6005 (valdeholm version 3)

sub EVENT_SPAWN {
  quest::setnexthpevent(70);
  quest::settimer("intro", 5);
}

sub EVENT_TIMER {
  if ($timer eq "intro") {
    quest::stoptimer("intro");
    quest::shout("So. Fergarin sends his 'invaders' to my throne. You will find the Krithgor are not so easily broken.");
    quest::emote("gestures, and Hethgar the Fell, Faelig Bearcaller, and High Lorekeeper Thair step forward to defend him.");
  }
}

sub EVENT_AGGRO {
  quest::shout("You dare raise a hand against your king? Then face the wrath of Valdeholm!");
}

sub EVENT_HP {
  if ($hpevent == 70) {
    quest::shout("Hold them! I will not be taken so easily.");
    quest::spawn2(600124, 0, 0, $npc->GetX() + 40, $npc->GetY(), $npc->GetZ(), 0);
    for (my $i = 0; $i < 4; $i++) {
      my $ang = $i * 90;
      my $x = $npc->GetX() + int(60 * cos($ang * 3.14159 / 180));
      my $y = $npc->GetY() + int(60 * sin($ang * 3.14159 / 180));
      quest::spawn2(600125, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(40);
  }
  elsif ($hpevent == 40) {
    quest::shout("No... I am the king of the Krithgor! I will not fall to the likes of you!");
    quest::emote("steels himself, drawing on the strength of his ancestors.");
    quest::sethp(70);
    for (my $i = 0; $i < 2; $i++) {
      quest::spawn2(600125, 0, 0, $npc->GetX() - 40 + ($i * 80), $npc->GetY() + 50, $npc->GetZ(), 0);
    }
    quest::setnexthpevent(14);
  }
  elsif ($hpevent == 14) {
    quest::shout("I surrender! I can not defeat you! Do not kill me! I don't want to be one of... them...");
    quest::emote("drops to one knee, his will broken. Finish him to claim the key to the royal crypts.");
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("The king of the Krithgor has fallen. Fergarin's work is done.");
}
