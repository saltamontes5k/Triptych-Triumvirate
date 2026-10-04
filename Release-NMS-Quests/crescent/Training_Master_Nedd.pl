sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600563);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600563 && quest::istaskactive(600563)) { quest::say("Five vermin. The yard is patient."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600563 && !quest::istaskcompleted(600563) && !quest::istaskactive(600563)) { quest::say("Your first [lesson]: five filthy vermin from the Hollows. Small, filthy, and everywhere."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("A beginning, well made. The yard will see you again."); }
  }
  if ($text=~/combat/i) {
    if (!quest::istaskactive(600563) && !quest::istaskcompleted(600563)) {
      quest::say("Five filthy vermin. Swing, shoot, or sing - just survive.");
      quest::assigntask(600563);
    }
    elsif (quest::istaskactive(600563)) { quest::say("Five vermin. The yard is patient."); }
    else { quest::say("A beginning, well made. The yard will see you again."); }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
