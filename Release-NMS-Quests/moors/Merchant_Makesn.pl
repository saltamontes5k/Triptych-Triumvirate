# Merchant Makesn - Blightfire Moors
# The Serpent's Spine :: A Widow's Last Memory (task 600211)
# Item: Mud-Caked Locket 52644

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail to you, traveler, and welcome to my humble store. I pray that your [" . quest::saylink("adventures") . "] have brought you more luck than mine.");
  }
  if ($text=~/adventures/i) {
    quest::say("Not long ago, after the death of my husband, my daughter and I decided to start anew. Unfortunately, during our journey here our caravan was attacked by [" . quest::saylink("gnolls") . "].");
  }
  if ($text=~/gnolls/i) {
    if (!quest::istaskactive(600211) && !quest::istaskcompleted(600211)) {
      quest::say("They took little of value - except a small trinket my dear husband gave me before his passing. They headed south toward their mines. Would you recover it for me?");
      quest::assigntask(600211);
    }
    else {
      quest::say("The gnolls headed south toward their mines. My locket, please.");
    }
  }
  # Jumjum Research (600450)
  if ($text=~/jumjum/i) {
    if (!quest::istaskactive(600450) && !quest::istaskcompleted(600450)) {
      quest::say("The bixies of Stone Hive grow a strange [jumjum]. A scholar would pay well for the research: their honey-covered journal, and some of the raw honey itself.");
      quest::assigntask(600450);
    }
    elsif (quest::istaskactive(600450)) {
      quest::say("The journal, and the raw honey. The hive workers carry both.");
    }
    else {
      quest::say("The research was well received, they tell me. My thanks again.");
    }
  }
  # Buzz on the Bixies (600483)
  if ($text=~/buzz/i) {
    if (!quest::istaskactive(600483) && !quest::istaskcompleted(600483)) {
      quest::say("The whole hive has a [buzz] about it lately - warriors and drones on the move. Thin them out before they decide the farm is theirs.");
      quest::assigntask(600483);
    }
    elsif (quest::istaskactive(600483)) {
      quest::say("The buzz, friend. Warriors and drones alike.");
    }
    else {
      quest::say("Quieter, isn't it? The farm thanks you.");
    }
  }
}

sub EVENT_ITEM {
  # Consume hand-ins only while their task is active (task system handles
  # completion); anything else is returned by the handin system.
  if (quest::istaskactive(600211)) {
    plugin::check_handin(\%itemcount, 52644 => 1);
  }
  if (quest::istaskactive(600450)) {
    plugin::check_handin(\%itemcount, 54639 => 1, 52639 => 5);
  }
}
