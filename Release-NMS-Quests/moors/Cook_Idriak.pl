sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600465,600466,600467);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600465 && quest::istaskactive(600465)) { quest::say("Six rat meats. The pot is empty."); $talked = 1; last; }
      if ($tsk == 600466 && quest::istaskactive(600466)) { quest::say("Four bixie meats. No flan without them."); $talked = 1; last; }
      if ($tsk == 600467 && quest::istaskactive(600467)) { quest::say("Eight moorwalkers. The garden still trembles."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600465 && !quest::istaskcompleted(600465) && !quest::istaskactive(600465)) { quest::say("The [stew] wants rat meat. Six cuts, from the big moor rats - the little ones are all gristle."); $talked = 1; last; }
        if ($tsk == 600466 && !quest::istaskcompleted(600466) && !quest::istaskactive(600466)) { quest::say("And a [flan] for the festival - bixie meat, four cuts."); $talked = 1; last; }
        if ($tsk == 600467 && !quest::istaskcompleted(600467) && !quest::istaskactive(600467)) { quest::say("And the [moorwalkers] - they trample the garden rows. Eight of them."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The pot thanks you, and so does Idriak. Eat well, friend - you have earned it."); }
  }
  if ($text=~/stew/i) {
    if (!quest::istaskactive(600465) && !quest::istaskcompleted(600465)) {
      quest::say("Six Rat Meats from the moonwhisker rats and their kin.");
      quest::assigntask(600465);
    }
    elsif (quest::istaskactive(600465)) { quest::say("Six rat meats. The pot is empty."); }
    else { quest::say("The pot thanks you, and so does Idriak. Eat well, friend - you have earned it."); }
  }
  if ($text=~/flan/i) {
    if (!quest::istaskactive(600466) && !quest::istaskcompleted(600466)) {
      quest::say("Four Bixie Meats from the hive drones.");
      quest::assigntask(600466);
    }
    elsif (quest::istaskactive(600466)) { quest::say("Four bixie meats. No flan without them."); }
    else { quest::say("The pot thanks you, and so does Idriak. Eat well, friend - you have earned it."); }
  }
  if ($text=~/heads/i) {
    if (!quest::istaskactive(600467) && !quest::istaskcompleted(600467)) {
      quest::say("Eight moorwalkers, any of the four packs. Then the garden is safe.");
      quest::assigntask(600467);
    }
    elsif (quest::istaskactive(600467)) { quest::say("Eight moorwalkers. The garden still trembles."); }
    else { quest::say("The pot thanks you, and so does Idriak. Eat well, friend - you have earned it."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600465)) { plugin::check_handin(\%itemcount, 13408 => 6); }
  if (quest::istaskactive(600466)) { plugin::check_handin(\%itemcount, 97305 => 4); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
