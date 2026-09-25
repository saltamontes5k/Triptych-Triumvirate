# Mistwalker - Sunderock Springs (raid event)
# Casts Boiling Steam (9258), a wide frontal AE, and once a minute summons four
# "a shadow in the mist" adds that fade after ten seconds. It also shifts form
# (Mistwalker's Mistform), trading raw defense for lower resists.

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::settimer("boil", 40);
    quest::settimer("shadows", 60);
  }
  else {
    quest::stoptimer("boil");
    quest::stoptimer("shadows");
  }
}

sub EVENT_TIMER {
  if ($timer eq "boil") {
    my $t = $npc->GetHateTop();
    $npc->SpellFinished(9258, $t) if $t;
  }
  elsif ($timer eq "shadows") {
    for (my $i = 0; $i < 4; $i++) {
      my $x = $npc->GetX() + int(40 * cos($i * 1.5708));
      my $y = $npc->GetY() + int(40 * sin($i * 1.5708));
      quest::spawn2(600268, 0, 0, $x, $y, $npc->GetZ(), 0);
    }
    quest::emote("coalesces out of the mist, and shadows step free of it.");
  }
}
