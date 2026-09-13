# Spirit of Truth - Crescent Reach (rune stones, SW Dragon's Grove)
# The Serpent's Spine :: Heshyrr's Wisdom (task 600242)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600242, 0)) {
      quest::say("You see me? Hm. Heshyrr's spiritstaff, then. Very well, little seeker: I am Truth. I was old when this stone was young, and I watched the ogres of Nokk raise their walls and forget their gods. Truth is what remains when everything else is taken away. Remember that, and tell the dragon's child you heard it.");
      quest::updatetaskactivity(600242, 0, 1);
    }
    else {
      quest::say("Truth waits for no one, little seeker. But it does wait.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
