# Kangur Vafta Veor - Valdeholm (TSS instanced raid encounter)
# npc: 600100   broodling: 600101   dz template: 6003 (valdeholm version 1)

sub EVENT_SPAWN {
  quest::settimer("brood", 45);
  quest::emote("clicks and hisses from the shadows of the ice, watching.");
}

sub EVENT_AGGRO {
  quest::shout("Kangur Vafta Veor shrieks, and the frozen lake trembles as her brood swarms to her defense!");
}

sub EVENT_TIMER {
  if ($timer eq "brood") {
    if ($npc->IsEngaged()) {
      my $count = quest::ChooseRandom(1, 2);
      for (my $i = 0; $i < $count; $i++) {
        my $x = $npc->GetX() + int(rand(90)) - 45;
        my $y = $npc->GetY() + int(rand(90)) - 45;
        my $z = $npc->GetZ();
        quest::spawn2(600101, 0, 0, $x, $y, $z, 0);
      }
    }
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Kangur Vafta Veor lets out one final, chilling shriek that echoes across the frozen lake.");
}

sub EVENT_SLAY {
  quest::emote("feasts upon her fallen prey.");
}
