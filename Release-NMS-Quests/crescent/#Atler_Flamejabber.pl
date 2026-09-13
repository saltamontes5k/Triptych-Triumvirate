# Atler Flamejabber - Crescent Reach
# The Serpent's Spine :: Peace and Understanding - Quellious' Favor (task 600220)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Beautiful, isn't it? I don't get out much, but when I do, I try to mend what's broken. These councilmembers are too lazy to address my issues. But there is a [" . quest::saylink("quarrel") . "] I cannot mend alone.");
  }
  if ($text=~/quarrel/i) {
    quest::say("The Fordel and the Midst make war with words - and worse. Only the Tranquil can show them peace. Will you seek [" . quest::saylink("Quellious") . "]' favor?");
  }
  if ($text=~/Quellious/i) {
    if (!quest::istaskactive(600220) && !quest::istaskcompleted(600220)) {
      quest::say("Seek the Avatar of Quellious in the Plane of Tranquility. Do as she asks, and there may be peace yet.");
      quest::assigntask(600220);
    }
    else {
      quest::say("The path to peace runs through the Plane of Tranquility, $name.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
