sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600572);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600572 && quest::istaskactive(600572)) { quest::say("Eight hedge devils. The bones still crawl."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600572 && !quest::istaskcompleted(600572) && !quest::istaskactive(600572)) { quest::say("Eight [hedge devils] crawl over the fallen dragon's bones in the moors fens. Drive them off."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The bones rest easier. The dreams are quiet tonight."); }
  }
  if ($text=~/dragon/i) {
    if (!quest::istaskactive(600572) && !quest::istaskcompleted(600572)) {
      quest::say("Eight hedge devils from the fens by the fallen dragon.");
      quest::assigntask(600572);
    }
    elsif (quest::istaskactive(600572)) { quest::say("Eight hedge devils. The bones still crawl."); }
    else { quest::say("The bones rest easier. The dreams are quiet tonight."); }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
