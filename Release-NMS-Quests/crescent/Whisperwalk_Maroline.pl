sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600571);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600571 && quest::istaskactive(600571)) { quest::say("One pristine feather. The wind still waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600571 && !quest::istaskcompleted(600571) && !quest::istaskactive(600571)) { quest::say("One [feather] - a Pristine Ridge Griffon Feather. They molt rarely; the old griffons carry the best."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("A pristine feather. The wind will remember this."); }
  }
  if ($text=~/cap/i) {
    if (!quest::istaskactive(600571) && !quest::istaskcompleted(600571)) {
      quest::say("One Pristine Ridge Griffon Feather. The old ones only.");
      quest::assigntask(600571);
    }
    elsif (quest::istaskactive(600571)) { quest::say("One pristine feather. The wind still waits."); }
    else { quest::say("A pristine feather. The wind will remember this."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600571)) { plugin::check_handin(\%itemcount, 52643 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
