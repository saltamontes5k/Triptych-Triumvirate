sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600440,600441,600442);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600440 && quest::istaskactive(600440)) { quest::say("Twelve warriors, twelve laborers. The hive still crawls."); $talked = 1; last; }
      if ($tsk == 600441 && quest::istaskactive(600441)) { quest::say("The drones and wasphers, friend. Twelve each."); $talked = 1; last; }
      if ($tsk == 600442 && quest::istaskactive(600442)) { quest::say("The Trickster, and its slavers. Golden, they say. Dead, I say."); $talked = 1; last; }
    }
    if (!$talked && quest::istaskactive(600589)) { quest::say("Neauza's plans? Hand them over, quick. The hive must never see them."); $talked = 1; }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600440 && !quest::istaskcompleted(600440) && !quest::istaskactive(600440)) { quest::say("The [warriors] and laborers of the hive swarm the ridge roads. Cull them before they swarm us."); $talked = 1; last; }
        if ($tsk == 600441 && !quest::istaskcompleted(600441) && !quest::istaskactive(600441)) { quest::say("They [prepare] for war - eggtenders and wasphers working the brood. Break it up."); $talked = 1; last; }
        if ($tsk == 600442 && !quest::istaskcompleted(600442) && !quest::istaskactive(600442)) { quest::say("And there is talk of [the Golden One] - a trickster in the hive, with slavers at its command."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("You have done the watch proud, $name. The hive will think twice before it stings Crescent Reach again."); }
  }
  if ($text=~/warriors/i) {
    if (!quest::istaskactive(600440) && !quest::istaskcompleted(600440)) {
      quest::say("Twelve warriors and twelve laborers. Thin the ranks and report back to me.");
      quest::assigntask(600440);
    }
    elsif (quest::istaskactive(600440)) { quest::say("Twelve warriors, twelve laborers. The hive still crawls."); }
    else { quest::say("You have done the watch proud, $name. The hive will think twice before it stings Crescent Reach again."); }
  }
  if ($text=~/war/i) {
    if (!quest::istaskactive(600441) && !quest::istaskcompleted(600441)) {
      quest::say("Twelve eggtender drones and twelve wasphers. Break the brood and come back.");
      quest::assigntask(600441);
    }
    elsif (quest::istaskactive(600441)) { quest::say("The drones and wasphers, friend. Twelve each."); }
    else { quest::say("You have done the watch proud, $name. The hive will think twice before it stings Crescent Reach again."); }
  }
  if ($text=~/golden/i) {
    if (!quest::istaskactive(600442) && !quest::istaskcompleted(600442)) {
      quest::say("The Stone Hive Trickster itself, and ten slavers for good measure. Then we will see about a reward.");
      quest::assigntask(600442);
    }
    elsif (quest::istaskactive(600442)) { quest::say("The Trickster, and its slavers. Golden, they say. Dead, I say."); }
    else { quest::say("You have done the watch proud, $name. The hive will think twice before it stings Crescent Reach again."); }
  }
}

sub EVENT_ITEM {
  # Consume the Muddied Bixie Plans while task 600589 is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600589)) {
    plugin::check_handin(\%itemcount, 54624 => 1);
  }
  plugin::return_items(\%itemcount);
}
