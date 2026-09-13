# a_shimmering_parchment - Crescent Reach (library, second level)
# The Serpent's Spine :: Myjinn's Enlightenment (task 600245)
# The Touch of the Six (84220).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600245, 1) && !$client->CountItem(84220)) {
      quest::say("Between the second shelf from the bottom, a parchment shimmers faintly: the Touch of the Six.");
      quest::summonitem(84220); # Touch of the Six
      quest::updatetaskactivity(600245, 1, 1);
    }
    else {
      quest::say("A faint shimmer plays over the shelf, there and gone.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
