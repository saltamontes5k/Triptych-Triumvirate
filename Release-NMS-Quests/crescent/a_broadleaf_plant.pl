# a_broadleaf_plant - Crescent Reach (Dragon's Grove, two spawn points)
# The Serpent's Spine :: Lizzrel's Path (task 600244)
# The Broadleaf (84213).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600244, 1) && !$client->CountItem(84213)) {
      quest::say("You carefully gather a great broadleaf plant, roots and all.");
      quest::summonitem(84213); # Broadleaf
      quest::updatetaskactivity(600244, 1, 1);
      quest::depop();
    }
    else {
      quest::say("A broad-leafed plant grows fat in the shade of the dragon trees.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
