# Captain Zheren - Sunderock Springs
# The Serpent's Spine :: Ashengate access group chain
# tasks: 600010 Scouting Sunderock, 600011 Dyn`leth's Artillery,
#        600012 The Ashengate Orders, 600013 Dyn`Leth's Mine
# Completing the first four flags the player to request raids from Sergeant Kazzar.
# faction: Crusade of the Scale (1095)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600010)) {
      quest::say("$name! Aren't you a sight for sore eyes! We set up this camp a few weeks ago to scout the lands controlled by Dyn`leth. We expected [opposition], but nothing like this.");
    }
    elsif (!quest::istaskcompleted(600011)) {
      quest::say("Welcome back, $name. Your scouting run was a great service to our [cause]. Now Dyn`leth's [artillery] threatens this very camp.");
    }
    elsif (!quest::istaskcompleted(600012)) {
      quest::say("The enemy's plans are moving. We need you to intercept a courier and bring us the [orders] he carries.");
    }
    elsif (!quest::istaskcompleted(600013)) {
      quest::say("Their mines supply the whole Legion. If you strike at the [quarry], we may yet break them.");
    }
    else {
      quest::say("You have done the Crusade a great service, $name. Speak with Sergeant Kazzar about the coming raids.");
    }
  }

  if ($text=~/opposition/i) {
    quest::say("Dyn`leth's armies control almost every piece of land between the mines to the east and the temple to the north. We are vastly outnumbered. Any strength you can lend to our [cause] would be much appreciated.");
  }

  if ($text=~/cause/i) {
    quest::say("We are the Crusade of the Scale! We will not rest until Dyn`leth is dead and the Scale of Veeshan has been reclaimed!");
    if (!quest::istaskactive(600010) && !quest::istaskcompleted(600010)) {
      quest::assigntask(600010);
    }
  }

  if ($text=~/artillery/i) {
    if (quest::istaskcompleted(600010) && !quest::istaskactive(600011) && !quest::istaskcompleted(600011)) {
      quest::say("Dyn`leth's forces have positioned catapults to fire on us. Kill the artillerists and smash their engines!");
      quest::assigntask(600011);
    }
  }

  if ($text=~/orders/i) {
    if (quest::istaskcompleted(600011) && !quest::istaskactive(600012) && !quest::istaskcompleted(600012)) {
      quest::say("A courier carries Dyn`leth's orders toward the mines. Stop him and bring the Ashengate Orders to me.");
      quest::assigntask(600012);
    }
  }

  if ($text=~/quarry/i) {
    if (quest::istaskcompleted(600012) && !quest::istaskactive(600013) && !quest::istaskcompleted(600013)) {
      quest::say("Strike at the mine itself: the slavedrivers and Overseer Vorsirus here in the valley, and the overseers and slaves within Vergalid.");
      quest::assigntask(600013);
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85698 => 1)) {
    quest::say("These are the orders we feared. Well done, $name.");
  }
  plugin::return_items(\%itemcount);
}
