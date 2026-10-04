sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600536,600537,600538,600539);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600536 && quest::istaskactive(600536)) { quest::say("A Simple Spiced Wine. The vats want more."); $talked = 1; last; }
      if ($tsk == 600537 && quest::istaskactive(600537)) { quest::say("A Peppy Juice. The market yawns."); $talked = 1; last; }
      if ($tsk == 600538 && quest::istaskactive(600538)) { quest::say("A Spicy Sunrise. The watch shivers."); $talked = 1; last; }
      if ($tsk == 600539 && quest::istaskactive(600539)) { quest::say("A Vanilla Coffee. The night is long."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600536 && !quest::istaskcompleted(600536) && !quest::istaskactive(600536)) { quest::say("A [wine] - a Simple Spiced Wine, brewed warm."); $talked = 1; last; }
        if ($tsk == 600537 && !quest::istaskcompleted(600537) && !quest::istaskactive(600537)) { quest::say("A [peppy] juice for the morning market - Peppy Juice."); $talked = 1; last; }
        if ($tsk == 600538 && !quest::istaskcompleted(600538) && !quest::istaskactive(600538)) { quest::say("A [spicy] sunrise for the night watch - a Spicy Sunrise."); $talked = 1; last; }
        if ($tsk == 600539 && !quest::istaskcompleted(600539) && !quest::istaskactive(600539)) { quest::say("And [coffee] - Vanilla Coffee, brewed strong."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The taps thank you. Teremun will pour you the first of the next batch."); }
  }
  if ($text=~/wine/i) {
    if (!quest::istaskactive(600536) && !quest::istaskcompleted(600536)) {
      quest::say("Brew a Simple Spiced Wine. The tavern orders stack.");
      quest::assigntask(600536);
    }
    elsif (quest::istaskactive(600536)) { quest::say("A Simple Spiced Wine. The vats want more."); }
    else { quest::say("The taps thank you. Teremun will pour you the first of the next batch."); }
  }
  if ($text=~/peppy/i) {
    if (!quest::istaskactive(600537) && !quest::istaskcompleted(600537)) {
      quest::say("Squeeze a Peppy Juice.");
      quest::assigntask(600537);
    }
    elsif (quest::istaskactive(600537)) { quest::say("A Peppy Juice. The market yawns."); }
    else { quest::say("The taps thank you. Teremun will pour you the first of the next batch."); }
  }
  if ($text=~/spicy/i) {
    if (!quest::istaskactive(600538) && !quest::istaskcompleted(600538)) {
      quest::say("Mix a Spicy Sunrise.");
      quest::assigntask(600538);
    }
    elsif (quest::istaskactive(600538)) { quest::say("A Spicy Sunrise. The watch shivers."); }
    else { quest::say("The taps thank you. Teremun will pour you the first of the next batch."); }
  }
  if ($text=~/coffee/i) {
    if (!quest::istaskactive(600539) && !quest::istaskcompleted(600539)) {
      quest::say("Brew a Vanilla Coffee.");
      quest::assigntask(600539);
    }
    elsif (quest::istaskactive(600539)) { quest::say("A Vanilla Coffee. The night is long."); }
    else { quest::say("The taps thank you. Teremun will pour you the first of the next batch."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600536)) { plugin::check_handin(\%itemcount, 98290 => 1); }
  if (quest::istaskactive(600537)) { plugin::check_handin(\%itemcount, 98257 => 1); }
  if (quest::istaskactive(600538)) { plugin::check_handin(\%itemcount, 58144 => 1); }
  if (quest::istaskactive(600539)) { plugin::check_handin(\%itemcount, 58165 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
