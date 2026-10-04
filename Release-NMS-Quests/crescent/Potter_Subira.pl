sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600548,600549);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600548 && quest::istaskactive(600548)) { quest::say("A Simple Pot. The kiln is hungry."); $talked = 1; last; }
      if ($tsk == 600549 && quest::istaskactive(600549)) { quest::say("A Simple Mug. The tavern is thirsty."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600548 && !quest::istaskcompleted(600548) && !quest::istaskactive(600548)) { quest::say("A [pot] - a Simple Pot, fired clean."); $talked = 1; last; }
        if ($tsk == 600549 && !quest::istaskcompleted(600549) && !quest::istaskactive(600549)) { quest::say("And a [mug] - a Simple Mug for the tavern."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Well fired. The kiln thanks you."); }
  }
  if ($text=~/pot/i) {
    if (!quest::istaskactive(600548) && !quest::istaskcompleted(600548)) {
      quest::say("Fire a Simple Pot. The kitchen waits.");
      quest::assigntask(600548);
    }
    elsif (quest::istaskactive(600548)) { quest::say("A Simple Pot. The kiln is hungry."); }
    else { quest::say("Well fired. The kiln thanks you."); }
  }
  if ($text=~/mug/i) {
    if (!quest::istaskactive(600549) && !quest::istaskcompleted(600549)) {
      quest::say("Throw a Simple Mug.");
      quest::assigntask(600549);
    }
    elsif (quest::istaskactive(600549)) { quest::say("A Simple Mug. The tavern is thirsty."); }
    else { quest::say("Well fired. The kiln thanks you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600548)) { plugin::check_handin(\%itemcount, 98284 => 1); }
  if (quest::istaskactive(600549)) { plugin::check_handin(\%itemcount, 98278 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
