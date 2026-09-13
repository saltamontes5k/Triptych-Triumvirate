# Avatar of Quellious the Tranquil - Plane of Tranquility
# The Serpent's Spine :: Peace and Understanding - Quellious' Favor (task 600220)
# Reward: Quellious' Wand of Tranquility 60395

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Beautiful, isn't it? This little pool. I come here when the weight of mortal quarrels grows heavy. You mean you don't feel it too?");
  }
  if ($text=~/feel|quarrel|peace/i) {
    quest::say("The Fordel and the Midst squabble without end, and their anger spills across the land. Tranquility is so very fleeting. Without constant vigilance, peace would never be maintained. Will you be my [" . quest::saylink("champion") . "]?");
  }
  if ($text=~/champion/i) {
    if (quest::istaskactive(600220)) {
      quest::say("Go to the Misty Thicket. Quell the drunken miscreants of both clans - not with death, but with a firm hand. Then return to me.");
    }
    elsif (quest::istaskcompleted(600220)) {
      quest::say("You have done well, champion of Tranquility. Take Quellious' wand, and may peace follow wherever you walk.");
    }
    else {
      quest::say("Speak with Atler Flamejabber in Crescent Reach; he knows how the quarrel began.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
