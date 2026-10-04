# Sorin - Goru`kar Mesa
# The Serpent's Spine :: Tuffein raid task set (tasks 600645-600647).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600645)) {
      quest::say("The Tuffein [stores] still stand. Ruin their larder.");
    }
    elsif (quest::istaskactive(600646)) {
      quest::say("[Dull] their edge - the satyrs carry it for them.");
    }
    elsif (quest::istaskactive(600647)) {
      quest::say("Rocks from the [gnoll] mines, into their biscuit barrels. I will keep a lantern lit for your return.");
    }
    elsif (!quest::istaskcompleted(600645)) {
      quest::say("The Tuffein [stores] grow fat while the mesa grows thin. Care to correct the balance?");
    }
    elsif (!quest::istaskcompleted(600646)) {
      quest::say("Their larder suffers. Now for their [weapons].");
    }
    else {
      quest::say("Stones in the biscuit barrels! I have not laughed so in seasons. Thank you, $name.");
    }
  }
  if ($text=~/stores/i && !quest::istaskactive(600645) && !quest::istaskcompleted(600645)) {
    quest::say("Scout the Tuffein camp, slay six of their medics guarding the stores, and report back to me.");
    quest::assigntask(600645);
  }
  if ($text=~/weapons/i && quest::istaskcompleted(600645) && !quest::istaskactive(600646) && !quest::istaskcompleted(600646)) {
    quest::say("To dull the edge, first dull the hand. Slay eight Tuffein satyrs and their forges will go cold.");
    quest::assigntask(600646);
  }
  if ($text=~/gnoll/i && quest::istaskcompleted(600646) && !quest::istaskactive(600647) && !quest::istaskcompleted(600647)) {
    quest::say("The gnoll mining camp in Blightfire Moors is full of piles of good hard rocks. Collect three, then sneak into the Tuffein camp and swap their stores. Hard biscuits for hard people.");
    quest::assigntask(600647);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
