# Laurentiu - Goru`kar Mesa
# The Serpent's Spine :: Vermin Elimination (task 600650, repeatable).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600650)) {
      quest::say("Wolves, bears, snakes - four of each and the camp sleeps easy.");
    }
    elsif (!quest::istaskcompleted(600650)) {
      quest::say("The [vermin] thicken every season. Are you willing to work?");
    }
    else {
      quest::say("Back again? The mesa's vermin never truly leave, $name. Four of each, whenever you are able.");
    }
  }
  if ($text=~/vermin/i && !quest::istaskactive(600650)) {
    quest::say("Four mesa wolves, four mesa bears, four diamondback snakes. Slay them and speak with me. I pay in gratitude and a little coin, whenever you can manage it.");
    quest::assigntask(600650);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
