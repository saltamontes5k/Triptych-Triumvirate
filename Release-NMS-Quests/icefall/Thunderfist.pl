# Thunderfist - Icefall Glacier
# The Serpent's Spine :: The Stonefed Shaman (task 600709)
# Reward: Nightmoon Stone 53692

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600709)) {
      quest::say("Gnashclaw still mutters over his [" . quest::saylink("sacred stone") . "]. Kill his orcs, kill the shaman, and bring me what remains of the stone.");
    }
    elsif (quest::istaskcompleted(600709)) {
      quest::say("The stonefed shaman is dust. The Nightmoon remember.");
    }
    else {
      quest::say("The kobolds' shaman gnawed his teeth on [" . quest::saylink("stone") . "] until the stone gnawed back. I want what is left of it.");
    }
  }
  if ($text=~/get stone/i || $text=~/stone/i) {
    if (!quest::istaskactive(600709) && !quest::istaskcompleted(600709)) {
      quest::say("Kill the Coldeye, then Gnashclaw Stonefed himself, and bring me the remains of his sacred stone.");
      quest::assigntask(600709);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
