sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600550,600551,600552,600553);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600550 && quest::istaskactive(600550)) { quest::say("A Simple Spring. Wound uneven, all of them."); $talked = 1; last; }
      if ($tsk == 600551 && quest::istaskactive(600551)) { quest::say("A Simple Pulley. The ropes still tangle."); $talked = 1; last; }
      if ($tsk == 600552 && quest::istaskactive(600552)) { quest::say("A Simple Animated Lure. The fish laugh at the old ones."); $talked = 1; last; }
      if ($tsk == 600553 && quest::istaskactive(600553)) { quest::say("A Simple Bow Cam. The bows pull hard without them."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600550 && !quest::istaskcompleted(600550) && !quest::istaskactive(600550)) { quest::say("A [spring] - a Simple Spring, wound even."); $talked = 1; last; }
        if ($tsk == 600551 && !quest::istaskcompleted(600551) && !quest::istaskactive(600551)) { quest::say("A [pulley] - a Simple Pulley, rigged true."); $talked = 1; last; }
        if ($tsk == 600552 && !quest::istaskcompleted(600552) && !quest::istaskactive(600552)) { quest::say("An [lure] - a Simple Animated Lure for the fishers."); $talked = 1; last; }
        if ($tsk == 600553 && !quest::istaskcompleted(600553) && !quest::istaskactive(600553)) { quest::say("And a [cam] - a Simple Bow Cam for the watch bows."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The gnomish bench thanks you. Precision is its own reward - but coin helps too."); }
  }
  if ($text=~/spring/i) {
    if (!quest::istaskactive(600550) && !quest::istaskcompleted(600550)) {
      quest::say("Wind a Simple Spring. The gnomish bench waits.");
      quest::assigntask(600550);
    }
    elsif (quest::istaskactive(600550)) { quest::say("A Simple Spring. Wound uneven, all of them."); }
    else { quest::say("The gnomish bench thanks you. Precision is its own reward - but coin helps too."); }
  }
  if ($text=~/pulley/i) {
    if (!quest::istaskactive(600551) && !quest::istaskcompleted(600551)) {
      quest::say("Rig a Simple Pulley.");
      quest::assigntask(600551);
    }
    elsif (quest::istaskactive(600551)) { quest::say("A Simple Pulley. The ropes still tangle."); }
    else { quest::say("The gnomish bench thanks you. Precision is its own reward - but coin helps too."); }
  }
  if ($text=~/lure/i) {
    if (!quest::istaskactive(600552) && !quest::istaskcompleted(600552)) {
      quest::say("Build a Simple Animated Lure.");
      quest::assigntask(600552);
    }
    elsif (quest::istaskactive(600552)) { quest::say("A Simple Animated Lure. The fish laugh at the old ones."); }
    else { quest::say("The gnomish bench thanks you. Precision is its own reward - but coin helps too."); }
  }
  if ($text=~/cam/i) {
    if (!quest::istaskactive(600553) && !quest::istaskcompleted(600553)) {
      quest::say("Fit a Simple Bow Cam.");
      quest::assigntask(600553);
    }
    elsif (quest::istaskactive(600553)) { quest::say("A Simple Bow Cam. The bows pull hard without them."); }
    else { quest::say("The gnomish bench thanks you. Precision is its own reward - but coin helps too."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600550)) { plugin::check_handin(\%itemcount, 58245 => 1); }
  if (quest::istaskactive(600551)) { plugin::check_handin(\%itemcount, 58246 => 1); }
  if (quest::istaskactive(600552)) { plugin::check_handin(\%itemcount, 58247 => 1); }
  if (quest::istaskactive(600553)) { plugin::check_handin(\%itemcount, 58248 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
