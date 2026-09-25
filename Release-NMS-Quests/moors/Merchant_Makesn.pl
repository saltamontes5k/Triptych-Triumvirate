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
}

sub EVENT_ITEM {
  # Consume the locket only while A Widow's Last Memory is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600211)) {
    plugin::check_handin(\%itemcount, 52644 => 1);
  }
}
