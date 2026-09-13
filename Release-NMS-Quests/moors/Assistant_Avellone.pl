# Assistant Avellone - Blightfire Moors
# The Serpent's Spine :: Jokes on You (task 600030) - Enchanter Drakkin illusion
# Items: Imposter Clue 54661, Devious Drakkin Potion 53589, Devious Drakkin Disguise 53590
# Located at -210, -1690 in the southeast swamp among the quest NPCs.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600030)) {
      quest::say("Do you have time to look into some [agricultural] technology for me? If not, I have a few [other tasks] for Vreshnar that I was going to look into today.");
    }
    elsif (!defined($qglobals{avellone_jokes_reward})) {
      quest::say("You found her! So Prunae had been replaced by one of the hive's own. A grim business. I have two ways you might remember it: a [" . quest::saylink("potion") . "] that mimics the Drakkin form, or a [" . quest::saylink("disguise") . "] that a skilled enchanter could learn from. Which would you prefer?");
    }
    else {
      quest::say("May that illusion serve you better than it served poor Prunae.");
    }
  }

  if ($text=~/other tasks/i) {
    quest::say("I need to track down [Prunae] and look into some [pranksters].");
  }
  if ($text=~/prunae/i) {
    quest::say("She helped Vreshnar put together the Bixie Illusion spell, but something went wrong. She donned an illusion and barged into Stone Hive, and hasn't been seen since. She seemed furious! Then yesterday, Vreshnar was stunned by a fellow Wyrmkin - it shouldn't have even been possible! We must find her.");
  }
  if ($text=~/pranksters/i) {
    if (!quest::istaskactive(600030) && !quest::istaskcompleted(600030)) {
      quest::say("Head into Stone Hive and search the slave hold. Find out whether Prunae has been imprisoned, or has turned bixie and is sharing our secrets within the hive.");
      quest::assigntask(600030);
    }
  }

  if ($text=~/potion/i && quest::istaskcompleted(600030) && !defined($qglobals{avellone_jokes_reward})) {
    quest::summonitem(53589);
    quest::setglobal("avellone_jokes_reward", 1, 5, "F");
    quest::say("A single draught of the Drakkin illusion. Use it wisely.");
  }
  if ($text=~/disguise/i && quest::istaskcompleted(600030) && !defined($qglobals{avellone_jokes_reward})) {
    quest::summonitem(53590);
    quest::setglobal("avellone_jokes_reward", 1, 5, "F");
    quest::say("Scribe this well, enchanter. It will teach you to wear the Drakkin form.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
