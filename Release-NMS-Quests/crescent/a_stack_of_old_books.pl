# a_stack_of_old_books - Crescent Reach (NE water, Dragon's Grove)
# The Serpent's Spine :: Myjinn's Enlightenment (task 600245)
# The book "Veeshan's Children" (84219).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600245, 2) && !$client->CountItem(84219)) {
      quest::say("Between the tree and the rock, a small stack of books waits above the waterline. The topmost is 'Veeshan's Children.'");
      quest::summonitem(84219); # Veeshan's Children
      quest::updatetaskactivity(600245, 2, 1);
    }
    else {
      quest::say("Old books, swollen with damp, stacked neatly against the rock.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
