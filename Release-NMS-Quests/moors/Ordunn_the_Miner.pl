sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600455,600456,600457,600458,600459);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600455 && quest::istaskactive(600455)) { quest::say("Ten miners, friend. The diggings still crawl."); $talked = 1; last; }
      if ($tsk == 600456 && quest::istaskactive(600456)) { quest::say("Ten breakers and the foreman. Deeper you go."); $talked = 1; last; }
      if ($tsk == 600457 && quest::istaskactive(600457)) { quest::say("Fifteen miners, and Scar. The Golden Pick waits."); $talked = 1; last; }
      if ($tsk == 600458 && quest::istaskactive(600458)) { quest::say("The mines, friend. Twelve and eight."); $talked = 1; last; }
      if ($tsk == 600459 && quest::istaskactive(600459)) { quest::say("Dogs and breakers. The quarry waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600455 && !quest::istaskcompleted(600455) && !quest::istaskactive(600455)) { quest::say("Grab a [pick] if you can swing one - but first swing it at the gnolls. Ten Mucktail miners."); $talked = 1; last; }
        if ($tsk == 600456 && !quest::istaskcompleted(600456) && !quest::istaskactive(600456)) { quest::say("Deeper now - the [rock breakers] hold the galleries, and a foreman cracks the whip over them."); $talked = 1; last; }
        if ($tsk == 600457 && !quest::istaskcompleted(600457) && !quest::istaskactive(600457)) { quest::say("The [Golden Pick] - that is what the boys call this. Pit Boss Scar runs the whole pit from the floor."); $talked = 1; last; }
        if ($tsk == 600458 && !quest::istaskcompleted(600458) && !quest::istaskactive(600458)) { quest::say("The [mines] themselves, then - miners and breakers both."); $talked = 1; last; }
        if ($tsk == 600459 && !quest::istaskcompleted(600459) && !quest::istaskactive(600459)) { quest::say("And the [quarry] - guard dogs and breakers."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
  if ($text=~/pick/i) {
    if (!quest::istaskactive(600455) && !quest::istaskcompleted(600455)) {
      quest::say("Ten Mucktail miners. Clear the lower diggings and report back.");
      quest::assigntask(600455);
    }
    elsif (quest::istaskactive(600455)) { quest::say("Ten miners, friend. The diggings still crawl."); }
    else { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
  if ($text=~/deeper/i) {
    if (!quest::istaskactive(600456) && !quest::istaskcompleted(600456)) {
      quest::say("Ten rock breakers, and the foreman with them.");
      quest::assigntask(600456);
    }
    elsif (quest::istaskactive(600456)) { quest::say("Ten breakers and the foreman. Deeper you go."); }
    else { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
  if ($text=~/golden/i) {
    if (!quest::istaskactive(600457) && !quest::istaskcompleted(600457)) {
      quest::say("Fifteen miners and Pit Boss Scar himself. Break the pit for good.");
      quest::assigntask(600457);
    }
    elsif (quest::istaskactive(600457)) { quest::say("Fifteen miners, and Scar. The Golden Pick waits."); }
    else { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
  if ($text=~/mines/i) {
    if (!quest::istaskactive(600458) && !quest::istaskcompleted(600458)) {
      quest::say("Twelve miners and eight breakers. Sweep the mines.");
      quest::assigntask(600458);
    }
    elsif (quest::istaskactive(600458)) { quest::say("The mines, friend. Twelve and eight."); }
    else { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
  if ($text=~/quarry/i) {
    if (!quest::istaskactive(600459) && !quest::istaskcompleted(600459)) {
      quest::say("Ten guard dogs and ten breakers. Empty the quarry.");
      quest::assigntask(600459);
    }
    elsif (quest::istaskactive(600459)) { quest::say("Dogs and breakers. The quarry waits."); }
    else { quest::say("The quarry's quiet for the first time in years. Ordunn owes you a pint, and Ordunn pays his debts."); }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
