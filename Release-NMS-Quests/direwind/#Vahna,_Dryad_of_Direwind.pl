# Vahna, Dryad of Direwind - Direwind Cliffs
# The Serpent's Spine :: Direwind #2: The Direwind Plaguebearers (task 600217)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Word of your attack on the Direwind boneyard has spread throughout the wilderness. You have brought hope to this forsaken land... But you have also invoked the ire of the Direwind gnolls.");
  }
  if ($text=~/Direwind/i) {
    quest::say("It was the gnolls that brought the Direwind. In its wake, the animals of these cliffs have become rabid and diseased. Gather your allies - I need you to make a stand against this spreading [" . quest::saylink("corruption") . "].");
  }
  if ($text=~/corruption/i) {
    if (!quest::istaskactive(600217) && !quest::istaskcompleted(600217)) {
      quest::say("Kill the Clan Direwind plague bearers and dispel the Direwind Currents. Bring me a Blight Pyre Ember and we will push back the corruption.");
      quest::assigntask(600217);
    }
    else {
      quest::say("The corruption spreads. Kill the plague bearers and dispel the currents.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
