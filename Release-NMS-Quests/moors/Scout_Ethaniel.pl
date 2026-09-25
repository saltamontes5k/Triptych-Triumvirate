# Scout Ethaniel - Blightfire Moors
# The Serpent's Spine :: bixie investigation chain (tasks 600080-600083)
# Rewards for #4: Blade of the Stonehive Front 53542, Hornet's Bane 53540,
#                 Staff of the Hiveslayer 53539, Wingcrusher 53541

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600080)) {
      quest::say("Shhh! Lower your voice lest you give us away. We are here to [discover] what the Bixies are up to and whether they mean Crescent Reach any ill will.");
    }
    elsif (!quest::istaskcompleted(600081)) {
      quest::say("Now that Verrin is safe back at Crescent Reach we can proceed. Will you collect samples of the Bixies' [jumjum]?");
    }
    elsif (!quest::istaskcompleted(600082)) {
      quest::say("Now that the council has the jumjum samples, we need to learn their [intentions]. Infiltrate the hive and find their plans.");
    }
    elsif (!quest::istaskcompleted(600083)) {
      quest::say("The plans speak of bixie [thralls] used for labor, kept in a haze. See if you can free them.");
    }
    else {
      quest::say("You have done Crescent Reach a great service, $name. The council will hear of it.");
    }
  }
  if ($text=~/discover/i) {
    if (!quest::istaskactive(600080) && !quest::istaskcompleted(600080)) {
      quest::say("Some time ago I sent in Verrin to uncover the Bixies' plans. I fear he has been exposed. Go there, find Verrin, and see that he returns unharmed.");
      quest::assigntask(600080);
    }
  }
  if ($text=~/jumjum/i) {
    if (quest::istaskcompleted(600080) && !quest::istaskactive(600081) && !quest::istaskcompleted(600081)) {
      quest::say("The bixies cultivate a strange, aggressive jumjum. Bring me samples of the various varieties.");
      quest::assigntask(600081);
    }
  }
  if ($text=~/intentions/i) {
    if (quest::istaskcompleted(600081) && !quest::istaskactive(600082) && !quest::istaskcompleted(600082)) {
      quest::say("Go into the hive and see what the bixies are planning. Kill their slavers and warriors if you must, and recover the pieces of their plan.");
      quest::assigntask(600082);
    }
  }
  if ($text=~/thralls/i) {
    if (quest::istaskcompleted(600082) && !quest::istaskactive(600083) && !quest::istaskcompleted(600083)) {
      quest::say("I glimpsed that the bixies use a substance which brings a haze upon their captives. Speak with the Farm Alchemist, recover some of the haze powder and the antidote, and free the thralls.");
      quest::assigntask(600083);
    }
  }
  if ($text=~/reward/i && quest::istaskcompleted(600083) && !defined($qglobals{ethaniel_reward})) {
    quest::say("Choose your reward: the [" . quest::saylink("blade") . "], [" . quest::saylink("hornet") . "], [" . quest::saylink("staff") . "], or [" . quest::saylink("wingcrusher") . "]?");
  }
  if ($text=~/blade/i && quest::istaskcompleted(600083) && !defined($qglobals{ethaniel_reward})) {
    quest::summonitem(53542); quest::setglobal("ethaniel_reward", 1, 5, "F");
  }
  if ($text=~/hornet/i && quest::istaskcompleted(600083) && !defined($qglobals{ethaniel_reward})) {
    quest::summonitem(53540); quest::setglobal("ethaniel_reward", 1, 5, "F");
  }
  if ($text=~/staff/i && quest::istaskcompleted(600083) && !defined($qglobals{ethaniel_reward})) {
    quest::summonitem(53539); quest::setglobal("ethaniel_reward", 1, 5, "F");
  }
  if ($text=~/wingcrusher/i && quest::istaskcompleted(600083) && !defined($qglobals{ethaniel_reward})) {
    quest::summonitem(53541); quest::setglobal("ethaniel_reward", 1, 5, "F");
  }
}

sub EVENT_ITEM {
  # Consume quest hand-ins only while their task is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600081)) {
    plugin::check_handin(\%itemcount, 36164 => 1);
    plugin::check_handin(\%itemcount, 36192 => 1);
  }
  if (quest::istaskactive(600082)) {
    plugin::check_handin(\%itemcount, 36165 => 1);
    plugin::check_handin(\%itemcount, 36166 => 1);
    plugin::check_handin(\%itemcount, 36167 => 1);
    plugin::check_handin(\%itemcount, 36168 => 1);
  }
  if (quest::istaskactive(600083)) {
    plugin::check_handin(\%itemcount, 36169 => 1);
    plugin::check_handin(\%itemcount, 36170 => 1);
  }
}
