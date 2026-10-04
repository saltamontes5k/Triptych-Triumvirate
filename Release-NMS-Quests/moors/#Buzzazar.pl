sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600448,600449);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600448 && quest::istaskactive(600448)) { quest::say("De wasphers and de gardeners, mon. Ten each."); $talked = 1; last; }
      if ($tsk == 600449 && quest::istaskactive(600449)) { quest::say("Seven pages, mon. De evolution waits."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600448 && !quest::istaskcompleted(600448) && !quest::istaskactive(600448)) { quest::say("De [wasphers] and gardeners work de fringe. Buzz in, Buzz out - cull dem."); $talked = 1; last; }
        if ($tsk == 600449 && !quest::istaskcompleted(600449) && !quest::istaskactive(600449)) { quest::say("Buzzazar seeks de [evolution] of de hive - seven pages, scattered in de combs. Bring dem."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("You have carried de whole story, mon. Buzzazar will remember. Bzzz."); }
  }
  if ($text=~/buzz/i) {
    if (!quest::istaskactive(600448) && !quest::istaskcompleted(600448)) {
      quest::say("Ten wasphers and ten gardeners. Buzz through dem and return.");
      quest::assigntask(600448);
    }
    elsif (quest::istaskactive(600448)) { quest::say("De wasphers and de gardeners, mon. Ten each."); }
    else { quest::say("You have carried de whole story, mon. Buzzazar will remember. Bzzz."); }
  }
  if ($text=~/evolution/i) {
    if (!quest::istaskactive(600449) && !quest::istaskcompleted(600449)) {
      quest::say("Seven pages of de Bixie Evolution. Any worker or drone may carry one.");
      quest::assigntask(600449);
    }
    elsif (quest::istaskactive(600449)) { quest::say("Seven pages, mon. De evolution waits."); }
    else { quest::say("You have carried de whole story, mon. Buzzazar will remember. Bzzz."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600449)) { plugin::check_handin(\%itemcount, 54643 => 1, 54644 => 1, 54645 => 1, 54646 => 1, 54647 => 1, 54648 => 1, 54649 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
