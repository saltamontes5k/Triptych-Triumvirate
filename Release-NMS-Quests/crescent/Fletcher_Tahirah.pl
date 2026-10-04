sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600580);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600580 && quest::istaskactive(600580)) { quest::say("Four straight branches. The benches wait."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600580 && !quest::istaskcompleted(600580) && !quest::istaskactive(600580)) { quest::say("Four [branches] - Straight Oak Treant Branches from the moor treants. Straight ones only."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Straight branches, well kept. The carving benches thank you."); }
  }
  if ($text=~/carving/i) {
    if (!quest::istaskactive(600580) && !quest::istaskcompleted(600580)) {
      quest::say("Four Straight Oak Treant Branches. Mind the treants.");
      quest::assigntask(600580);
    }
    elsif (quest::istaskactive(600580)) { quest::say("Four straight branches. The benches wait."); }
    else { quest::say("Straight branches, well kept. The carving benches thank you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600580)) { plugin::check_handin(\%itemcount, 97053 => 4); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
