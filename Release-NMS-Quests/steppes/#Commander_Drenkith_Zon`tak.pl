#Commander_Drenkith_Zon`tak.pl
# Commander Drenkith Zon`Tak - The Steppes (far northern cave)
# The Serpent's Spine :: Finding Felena #4 (600413).
# Hail him and say 'I am here to free Felena' to draw him into the fight.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("A visitor to my cave. You are either lost, brave, or very foolish, softskin. Speak your business quickly.");
  }
  if ($text=~/i am here to free felena/i) {
    if (quest::istaskactive(600413)) {
      quest::say("The dwarf whelp? Ha! She screams her father's name still. You will join her -- KILL THEM ALL!");
      quest::attack($name);
    }
    else {
      quest::say("Felena? Names mean nothing here. Be gone.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
