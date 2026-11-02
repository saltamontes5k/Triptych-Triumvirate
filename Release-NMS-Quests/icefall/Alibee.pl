# Alibee - Icefall Glacier
# The Serpent's Spine :: Timmi Fell Down the Well! (task 600701)
# Reward: Dog Whistle 53695

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(600701)) {
      quest::say("Timmi is home safe thanks to you, $name. The wolves still howl, but my boy sleeps sound.");
    }
    elsif (quest::istaskactive(600701)) {
      quest::say("Timmi is still down the [" . quest::saylink("well") . "] to the south! La`See knows the way - follow the wolf and keep her safe.");
    }
    else {
      quest::say("Please, have you seen my boy? Timmi chased his [" . quest::saylink("dog") . "] down the old well and the outcasts have him caged!");
    }
  }
  if ($text=~/dog/i || $text=~/well/i) {
    if (!quest::istaskactive(600701) && !quest::istaskcompleted(600701)) {
      quest::say("Bless you! La`See will lead you to the well. Kill the outcasts, open the cage, and bring my Timmi home.");
      quest::assigntask(600701);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
