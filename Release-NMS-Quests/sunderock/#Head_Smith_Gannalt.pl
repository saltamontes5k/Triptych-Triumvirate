# Head Smith Gannalt - Sunderock Springs (rare, Elite's Insignia source)
# Hits harder as his health drops: starting in the 400s, then quadding for
# ~1k once he is below a quarter. Frequently carries an Insignia of
# Ashengate's Elite (85699) for Armorer Arkin's task.

sub EVENT_COMBAT {
  if ($combat_state == 1) {
    quest::setnexthpevent(75);
  }
}

sub EVENT_HP {
  if ($hpevent == 75) {
    $npc->ModifyNPCStat("maxdmg", "650");
    quest::emote("drives his hammer down harder as the fight drags on.");
    quest::setnexthpevent(50);
  }
  elsif ($hpevent == 50) {
    $npc->ModifyNPCStat("maxdmg", "800");
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    $npc->ModifyNPCStat("maxdmg", "1050");
    quest::emote("goes berserk, lashing out in every direction!");
    quest::setnexthpevent(-1);
  }
}
