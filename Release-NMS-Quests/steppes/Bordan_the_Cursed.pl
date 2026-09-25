# Bordan the Cursed - The Steppes
# The Serpent's Spine :: Treasure of the Dead (task 600216)
# Item: Plundered Krithgorian Knife 53630

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Don't come near! This curse causes a slow death, though so far it hasn't killed me. Not far from here is an old burial ground where the giants buried their dead. Would you be [" . quest::saylink("willing") . "] to enter the tomb where I lost the last of my life and find who did this to me?");
  }
  if ($text=~/willing/i) {
    if (!quest::istaskactive(600216) && !quest::istaskcompleted(600216)) {
      quest::say("Thank you. Search the burial grounds for a plundered Krithgorian knife - it may reveal who cursed me. Bring it back to me.");
      quest::assigntask(600216);
    }
    else {
      quest::say("The burial grounds lie nearby. Bring me the plundered knife.");
    }
  }
}

sub EVENT_ITEM {
  # Consume the knife only while Treasure of the Dead is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600216)) {
    plugin::check_handin(\%itemcount, 53630 => 1);
  }
}
