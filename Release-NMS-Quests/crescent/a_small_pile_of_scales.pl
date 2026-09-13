# a_small_pile_of_scales - Crescent Reach (inn, top floor)
# The Serpent's Spine :: Lizzrel's Path (task 600244)
# The Drakkin Scale (84214).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600244, 2) && !$client->CountItem(84214)) {
      quest::emote("glints softly among what you first took for pebbles.");
      quest::say("You pick out a perfect Drakkin Scale from the little pile.");
      quest::summonitem(84214); # Drakkin Scale
      quest::updatetaskactivity(600244, 2, 1);
      quest::depop();
    }
    else {
      quest::say("A small pile of what appears to be shiny stones. Up close, they look very much like scales.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
