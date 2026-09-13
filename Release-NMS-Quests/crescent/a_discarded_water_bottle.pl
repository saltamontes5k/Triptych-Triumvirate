# a_discarded_water_bottle - Crescent Reach (waterfall pool, the Hollow)
# The Serpent's Spine :: Reakash's Serenity (task 600246)
# The Sample of Pure Water (84201).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600246, 0) && !$client->CountItem(84201)) {
      quest::say("You wade to where the falls strike the pool and submerge a clean bottle. It fills with cold, impossibly clear water.");
      quest::summonitem(84201); # Sample of Pure Water
      quest::updatetaskactivity(600246, 0, 1);
    }
    else {
      quest::say("An empty bottle bobs gently in the churning pool below the falls.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
