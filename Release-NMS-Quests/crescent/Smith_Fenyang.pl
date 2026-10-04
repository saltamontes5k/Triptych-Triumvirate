sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600574,600524);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600574 && quest::istaskactive(600574)) { quest::say("Four bricks of ore. The shipment waits."); $talked = 1; last; }
      if ($tsk == 600524 && quest::istaskactive(600524)) { quest::say("A Simple Repaired Plate. The racks still stand empty."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600574 && !quest::istaskcompleted(600574) && !quest::istaskactive(600574)) { quest::say("First - [ore] for the shipment. Four Small Bricks of Ore, from the merchants or the mines."); $talked = 1; last; }
        if ($tsk == 600524 && !quest::istaskcompleted(600524) && !quest::istaskactive(600524)) { quest::say("And a [plate] - a Simple Repaired Plate for the watch racks."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The watch thanks you. The guardhouse forge will remember your name."); }
  }
  if ($text=~/ore/i) {
    if (!quest::istaskactive(600574) && !quest::istaskcompleted(600574)) {
      quest::say("Four Small Bricks of Ore. The forge waits.");
      quest::assigntask(600574);
    }
    elsif (quest::istaskactive(600574)) { quest::say("Four bricks of ore. The shipment waits."); }
    else { quest::say("The watch thanks you. The guardhouse forge will remember your name."); }
  }
  if ($text=~/plate/i) {
    if (!quest::istaskactive(600524) && !quest::istaskcompleted(600524)) {
      quest::say("A Simple Repaired Plate. Make it whole again.");
      quest::assigntask(600524);
    }
    elsif (quest::istaskactive(600524)) { quest::say("A Simple Repaired Plate. The racks still stand empty."); }
    else { quest::say("The watch thanks you. The guardhouse forge will remember your name."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600574)) { plugin::check_handin(\%itemcount, 10501 => 4); }
  if (quest::istaskactive(600524)) { plugin::check_handin(\%itemcount, 98283 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
