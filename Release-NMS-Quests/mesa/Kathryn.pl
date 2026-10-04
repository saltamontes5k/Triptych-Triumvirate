# Kathryn - Goru`kar Mesa
# The Serpent's Spine :: hail target for the Ciodaru and Kathryn series
# (tasks 600665, 600676). She lives atop the mesa.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600665) || (quest::istaskactive(600676))) {
      quest::say("Ciodaru? He of the ridiculous shoulders and the longer silences? Tell him. . . tell him the mesa is quieter without his nonsense. And that I noticed he noticed.");
    }
    elsif (quest::istaskcompleted(600676)) {
      quest::say("The feathers are woven into my braid, $name. A dryad does not forget such things.");
    }
    else {
      quest::say("The wind speaks softly up here, traveler. What brings you to my perch?");
    }
  }
}

sub EVENT_ITEM {
  # Consume the gift box feathers while task 600676 is active (task system
  # handles completion); anything else is returned.
  if (quest::istaskactive(600676)) {
    plugin::check_handin(\%itemcount, 57015 => 2);
  }
  plugin::return_items(\%itemcount);
}
