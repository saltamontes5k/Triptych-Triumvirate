sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600540,600541,600542,600543);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600540 && quest::istaskactive(600540)) { quest::say("A Simple Black Dye. The vats are pale."); $talked = 1; last; }
      if ($tsk == 600541 && quest::istaskactive(600541)) { quest::say("A Simple Blue Dye. Still colorless."); $talked = 1; last; }
      if ($tsk == 600542 && quest::istaskactive(600542)) { quest::say("A Simple Green Dye. The moss grows old waiting."); $talked = 1; last; }
      if ($tsk == 600543 && quest::istaskactive(600543)) { quest::say("A Simple Red Dye. The banners wait."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600540 && !quest::istaskcompleted(600540) && !quest::istaskactive(600540)) { quest::say("[Black] first - a Simple Black Dye, brewed dark."); $talked = 1; last; }
        if ($tsk == 600541 && !quest::istaskcompleted(600541) && !quest::istaskactive(600541)) { quest::say("[Blue] next - a Simple Blue Dye, sky-bright."); $talked = 1; last; }
        if ($tsk == 600542 && !quest::istaskcompleted(600542) && !quest::istaskactive(600542)) { quest::say("[Green] - a Simple Green Dye, moss-fresh."); $talked = 1; last; }
        if ($tsk == 600543 && !quest::istaskcompleted(600543) && !quest::istaskactive(600543)) { quest::say("And [red] - a Simple Red Dye, blood-bright."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The vats thank you. Color at last!"); }
  }
  if ($text=~/black/i) {
    if (!quest::istaskactive(600540) && !quest::istaskcompleted(600540)) {
      quest::say("Brew a Simple Black Dye. The tailors wait.");
      quest::assigntask(600540);
    }
    elsif (quest::istaskactive(600540)) { quest::say("A Simple Black Dye. The vats are pale."); }
    else { quest::say("The vats thank you. Color at last!"); }
  }
  if ($text=~/blue/i) {
    if (!quest::istaskactive(600541) && !quest::istaskcompleted(600541)) {
      quest::say("Brew a Simple Blue Dye.");
      quest::assigntask(600541);
    }
    elsif (quest::istaskactive(600541)) { quest::say("A Simple Blue Dye. Still colorless."); }
    else { quest::say("The vats thank you. Color at last!"); }
  }
  if ($text=~/green/i) {
    if (!quest::istaskactive(600542) && !quest::istaskcompleted(600542)) {
      quest::say("Brew a Simple Green Dye.");
      quest::assigntask(600542);
    }
    elsif (quest::istaskactive(600542)) { quest::say("A Simple Green Dye. The moss grows old waiting."); }
    else { quest::say("The vats thank you. Color at last!"); }
  }
  if ($text=~/red/i) {
    if (!quest::istaskactive(600543) && !quest::istaskcompleted(600543)) {
      quest::say("Brew a Simple Red Dye.");
      quest::assigntask(600543);
    }
    elsif (quest::istaskactive(600543)) { quest::say("A Simple Red Dye. The banners wait."); }
    else { quest::say("The vats thank you. Color at last!"); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600540)) { plugin::check_handin(\%itemcount, 98268 => 1); }
  if (quest::istaskactive(600541)) { plugin::check_handin(\%itemcount, 98269 => 1); }
  if (quest::istaskactive(600542)) { plugin::check_handin(\%itemcount, 98275 => 1); }
  if (quest::istaskactive(600543)) { plugin::check_handin(\%itemcount, 98286 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
