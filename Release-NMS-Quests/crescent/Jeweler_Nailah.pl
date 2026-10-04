sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600525);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600525 && quest::istaskactive(600525)) { quest::say("A Simple Ring. The setting waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600525 && !quest::istaskcompleted(600525) && !quest::istaskactive(600525)) { quest::say("A [ring] - a Simple Ring, well set. Nothing fancy; the ceremony wants simple."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("A fine setting, well made. The bench thanks you."); }
  }
  if ($text=~/ring/i) {
    if (!quest::istaskactive(600525) && !quest::istaskcompleted(600525)) {
      quest::say("A Simple Ring. Set it true.");
      quest::assigntask(600525);
    }
    elsif (quest::istaskactive(600525)) { quest::say("A Simple Ring. The setting waits."); }
    else { quest::say("A fine setting, well made. The bench thanks you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600525)) { plugin::check_handin(\%itemcount, 58112 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
