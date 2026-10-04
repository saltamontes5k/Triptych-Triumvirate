sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600451,600482,600481);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600451 && quest::istaskactive(600451)) { quest::say("Six stingers. The craft waits."); $talked = 1; last; }
      if ($tsk == 600482 && quest::istaskactive(600482)) { quest::say("Six lightstones. The lamps still shine."); $talked = 1; last; }
      if ($tsk == 600481 && quest::istaskactive(600481)) { quest::say("Four witches, hunter. All of them."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600451 && !quest::istaskcompleted(600451) && !quest::istaskactive(600451)) { quest::say("First - [venom]. The Stone Hive carries stingers I need for the craft. Six of them."); $talked = 1; last; }
        if ($tsk == 600482 && !quest::istaskcompleted(600482) && !quest::istaskactive(600482)) { quest::say("The [witchlamps] - their lightstones feed the witches' sight. Six of them, burned out."); $talked = 1; last; }
        if ($tsk == 600481 && !quest::istaskcompleted(600481) && !quest::istaskactive(600481)) { quest::say("And the [witches] themselves. Four of them hold the moors: Agatha the Gray, Sinead the Scarlet, Ursula the Green, Eralynn the Shadow."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The road is lighter for your work, and the witches quieter. Zan will remember."); }
  }
  if ($text=~/stingers/i) {
    if (!quest::istaskactive(600451) && !quest::istaskcompleted(600451)) {
      quest::say("Six Venomous Stonehive Stingers from the hive bixies.");
      quest::assigntask(600451);
    }
    elsif (quest::istaskactive(600451)) { quest::say("Six stingers. The craft waits."); }
    else { quest::say("The road is lighter for your work, and the witches quieter. Zan will remember."); }
  }
  if ($text=~/lamps/i) {
    if (!quest::istaskactive(600482) && !quest::istaskcompleted(600482)) {
      quest::say("Six Witchlamp Lightstones from the lamps themselves.");
      quest::assigntask(600482);
    }
    elsif (quest::istaskactive(600482)) { quest::say("Six lightstones. The lamps still shine."); }
    else { quest::say("The road is lighter for your work, and the witches quieter. Zan will remember."); }
  }
  if ($text=~/witches/i) {
    if (!quest::istaskactive(600481) && !quest::istaskcompleted(600481)) {
      quest::say("All four witches. Agatha, Sinead, Ursula, Eralynn. Then the moors breathe.");
      quest::assigntask(600481);
    }
    elsif (quest::istaskactive(600481)) { quest::say("Four witches, hunter. All of them."); }
    else { quest::say("The road is lighter for your work, and the witches quieter. Zan will remember."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600451)) { plugin::check_handin(\%itemcount, 85757 => 6); }
  if (quest::istaskactive(600482)) { plugin::check_handin(\%itemcount, 85754 => 6); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
