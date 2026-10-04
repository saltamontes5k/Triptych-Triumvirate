sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600576);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600576 && quest::istaskactive(600576)) { quest::say("Two Simple Spiced Wines. The craft waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600576 && !quest::istaskcompleted(600576) && !quest::istaskactive(600576)) { quest::say("Show me the [craft] - two Simple Spiced Wines, brewed nowhere but proven here."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("A brewer of promise! The vats will remember you."); }
  }
  if ($text=~/craft/i) {
    if (!quest::istaskactive(600576) && !quest::istaskcompleted(600576)) {
      quest::say("Two Simple Spiced Wines. Brew them clean.");
      quest::assigntask(600576);
    }
    elsif (quest::istaskactive(600576)) { quest::say("Two Simple Spiced Wines. The craft waits."); }
    else { quest::say("A brewer of promise! The vats will remember you."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600576)) { plugin::check_handin(\%itemcount, 98290 => 2); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
