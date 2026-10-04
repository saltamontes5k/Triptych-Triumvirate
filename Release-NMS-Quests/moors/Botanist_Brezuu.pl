sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600460,600461,600462,600463);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600460 && quest::istaskactive(600460)) { quest::say("Five shambling vegetables. The beds are empty."); $talked = 1; last; }
      if ($tsk == 600461 && quest::istaskactive(600461)) { quest::say("Four seed pods. Curious ones."); $talked = 1; last; }
      if ($tsk == 600462 && quest::istaskactive(600462)) { quest::say("Five saps. The trees still weep."); $talked = 1; last; }
      if ($tsk == 600463 && quest::istaskactive(600463)) { quest::say("Four ooze buds. Sticky business."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600460 && !quest::istaskcompleted(600460) && !quest::istaskactive(600460)) { quest::say("The [plants] - shambling vegetables from the walking shrubs. Five will do."); $talked = 1; last; }
        if ($tsk == 600461 && !quest::istaskcompleted(600461) && !quest::istaskactive(600461)) { quest::say("And a [seed] pod or four - the curious kind, from the briars."); $talked = 1; last; }
        if ($tsk == 600462 && !quest::istaskcompleted(600462) && !quest::istaskactive(600462)) { quest::say("The treants weep a strange [sap]. Five measures."); $talked = 1; last; }
        if ($tsk == 600463 && !quest::istaskcompleted(600463) && !quest::istaskactive(600463)) { quest::say("And the [ooze] - green ooze buds, four of them. Wear gloves you do not like."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."); }
  }
  if ($text=~/plants/i) {
    if (!quest::istaskactive(600460) && !quest::istaskcompleted(600460)) {
      quest::say("Five Shambling Vegetables. Mind the thorns.");
      quest::assigntask(600460);
    }
    elsif (quest::istaskactive(600460)) { quest::say("Five shambling vegetables. The beds are empty."); }
    else { quest::say("Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."); }
  }
  if ($text=~/seed/i) {
    if (!quest::istaskactive(600461) && !quest::istaskcompleted(600461)) {
      quest::say("Four Seed Pods from the briar thorns.");
      quest::assigntask(600461);
    }
    elsif (quest::istaskactive(600461)) { quest::say("Four seed pods. Curious ones."); }
    else { quest::say("Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."); }
  }
  if ($text=~/sap/i) {
    if (!quest::istaskactive(600462) && !quest::istaskcompleted(600462)) {
      quest::say("Five Treant Saps from the rotwood treants.");
      quest::assigntask(600462);
    }
    elsif (quest::istaskactive(600462)) { quest::say("Five saps. The trees still weep."); }
    else { quest::say("Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."); }
  }
  if ($text=~/ooze/i) {
    if (!quest::istaskactive(600463) && !quest::istaskcompleted(600463)) {
      quest::say("Four Green Ooze Buds from the green oozes.");
      quest::assigntask(600463);
    }
    elsif (quest::istaskactive(600463)) { quest::say("Four ooze buds. Sticky business."); }
    else { quest::say("Splendid specimens, all of them! The council gardeners will hear of this. Come back when the moors bloom again."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600460)) { plugin::check_handin(\%itemcount, 97048 => 5); }
  if (quest::istaskactive(600461)) { plugin::check_handin(\%itemcount, 54656 => 4); }
  if (quest::istaskactive(600462)) { plugin::check_handin(\%itemcount, 97054 => 5); }
  if (quest::istaskactive(600463)) { plugin::check_handin(\%itemcount, 85758 => 4); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
