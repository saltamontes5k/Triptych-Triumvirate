sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600526);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600526 && quest::istaskactive(600526)) { quest::say("A Simple Belt. The militia waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600526 && !quest::istaskcompleted(600526) && !quest::istaskactive(600526)) { quest::say("A [belt] - a Simple Belt, stitched tight. The militia wants simple and strong."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Fine work. The stall thanks you, and so does the militia."); }
  }
  if ($text=~/belt/i) {
    if (!quest::istaskactive(600526) && !quest::istaskcompleted(600526)) {
      quest::say("A Simple Belt. Stitch it well.");
      quest::assigntask(600526);
    }
    elsif (quest::istaskactive(600526)) { quest::say("A Simple Belt. The militia waits."); }
    else { quest::say("Fine work. The stall thanks you, and so does the militia."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600526)) { plugin::check_handin(\%itemcount, 58086 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
