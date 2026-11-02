# Portal of War - The Steppes
# The Serpent's Spine :: Portal of War raid event (5 phases).
# Hand in the three Portal Fragments (87206, 87207, 87208) from the
# Rebuild the Portal arc to heal the portal and begin the assault.
# 1120002372 #Pummelcrush, 1120002373 #Vetiki, 1120002374 #Vegeroth,
# 1120002375 #Earthrender, 1120002376 #Earthcrusher, 1120002377 #Demeton

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::get_data('portal_of_war_active') >= 1) {
      quest::say("The enemy pours through even now. Fight!");
    }
    else {
      quest::say("A gateway half-dead, held shut by age and ruin. What was broken can be [" . quest::saylink("repaired") . "] - if you carry the fragments.");
    }
  }
  if ($text=~/repaired/i) {
    quest::say("Three fragments, set into the arch. When the portal is whole, whatever waits on the other side will come through. Be ready.");
  }
}

sub EVENT_ITEM {
  my $frags = 0;
  foreach my $f (87206, 87207, 87208) {{
    $frags += $itemcount{$f} if exists $itemcount{$f};
  }}
  if ($frags >= 3) {
    quest::set_data('portal_of_war_active', '1', '14400');
    quest::emote("swallows the three fragments whole. Its runes flare white-hot, and the air begins to scream.");
    quest::ze(15, "The Portal of War blazes to life! Something huge is pushing through!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    quest::unique_spawn(1120002372, 0, 0, $x + 60, $y, $z, 0);
    for (1 .. 4) {{
      quest::spawn2(399131, 0, 0, $x + int(rand(120)) - 60, $y + int(rand(120)) - 60, $z, 0);
    }}
    if ($frags > 3) {{
      plugin::return_items(\\%itemcount);
    }}
    return 1;
  }
  plugin::return_items(\\%itemcount);
}
