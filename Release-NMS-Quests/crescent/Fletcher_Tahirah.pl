# Fletcher Tahirah - Crescent Reach (Artisans' Row)
# The Serpent's Spine :: carving wood supply (task 600580)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Carving wood, carving wood - everyone wants carving wood and no one brings any. The treants of the moors shed the best branches.");
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
  if ($text=~/branches/i) {
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
}
