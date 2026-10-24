# Ironskull - Icefall Glacier
# The Serpent's Spine :: Skullcups (task 600720)
# Reward: Skullcup Charm 53636

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600720)) {
      quest::say("Fifteen kobolds. Four cups. Do not come back short.");
    }
    elsif (quest::istaskcompleted(600720)) {
      quest::say("The cups sing when you walk past. The kobolds hear it in their dreams.");
    }
    else {
      quest::say("I [" . quest::saylink("I want to make them sad") . "]. The kobolds. I want to make them very sad.");
    }
  }
  if ($text=~/I want to make them sad/i && !quest::istaskactive(600720) && !quest::istaskcompleted(600720)) {
    quest::say("Kill fifteen kobolds and bring me four of their skullcups. Then we drink, and they weep.");
    quest::assigntask(600720);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
