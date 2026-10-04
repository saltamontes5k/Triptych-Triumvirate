sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600570);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600570 && quest::istaskactive(600570)) { quest::say("Four feathers. The ridge still screams."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600570 && !quest::istaskcompleted(600570) && !quest::istaskactive(600570)) { quest::say("Four [feathers] - Griffon Feathers from the ridge griffons of the moors. Mind the beaks."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Four feathers, well kept. The aviary thanks you."); }
  }
  if ($text=~/griffon/i) {
    if (!quest::istaskactive(600570) && !quest::istaskcompleted(600570)) {
      quest::say("Four Griffon Feathers from the ridge griffons.");
      quest::assigntask(600570);
    }
    elsif (quest::istaskactive(600570)) { quest::say("Four feathers. The ridge still screams."); }
    else { quest::say("Four feathers, well kept. The aviary thanks you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600570)) { plugin::check_handin(\%itemcount, 16538 => 4); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
