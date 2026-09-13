# a_crate_of_lemonade - Crescent Reach (puma cave, the Hollow)
# The Serpent's Spine :: Party Preparation (task 600250)
# Uliean's abandoned crate of fizzy lemonade (52638).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600250, 0) && !$client->CountItem(52638)) {
      quest::say("You pry open the crate. Bottles clink inside; one is still sealed and full - Fizzy Lemonade.");
      quest::summonitem(52638); # Fizzy Lemonade
      quest::updatetaskactivity(600250, 0, 1);
    }
    else {
      quest::say("A battered crate stenciled 'SHIVRA'S - FINEST FIZZY LEMONADE.' Empty, save for one bottle rolling around inside.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
