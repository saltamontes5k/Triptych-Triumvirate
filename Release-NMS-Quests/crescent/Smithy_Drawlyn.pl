sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600520,600521,600522,600523);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600520 && quest::istaskactive(600520)) { quest::say("A Simple Stud. The forge is hot."); $talked = 1; last; }
      if ($tsk == 600521 && quest::istaskactive(600521)) { quest::say("A Simple Chisel. The masons wait."); $talked = 1; last; }
      if ($tsk == 600522 && quest::istaskactive(600522)) { quest::say("A Simple File. The armory grinds its teeth."); $talked = 1; last; }
      if ($tsk == 600523 && quest::istaskactive(600523)) { quest::say("A Simple Clasp. The plates still rattle."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600520 && !quest::istaskcompleted(600520) && !quest::istaskactive(600520)) { quest::say("First a [stud] - a Simple Stud, forged clean."); $talked = 1; last; }
        if ($tsk == 600521 && !quest::istaskcompleted(600521) && !quest::istaskactive(600521)) { quest::say("And a [chisel] - a Simple Chisel for the stonecutters."); $talked = 1; last; }
        if ($tsk == 600522 && !quest::istaskcompleted(600522) && !quest::istaskactive(600522)) { quest::say("A [file] next - a Simple File, well tempered."); $talked = 1; last; }
        if ($tsk == 600523 && !quest::istaskcompleted(600523) && !quest::istaskactive(600523)) { quest::say("And a [clasp] - a Simple Clasp to hold the charter plates."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The council smiths thank you. The forge rests a little easier tonight."); }
  }
  if ($text=~/stud/i) {
    if (!quest::istaskactive(600520) && !quest::istaskcompleted(600520)) {
      quest::say("Forge a Simple Stud and bring it here. The artisans wait.");
      quest::assigntask(600520);
    }
    elsif (quest::istaskactive(600520)) { quest::say("A Simple Stud. The forge is hot."); }
    else { quest::say("The council smiths thank you. The forge rests a little easier tonight."); }
  }
  if ($text=~/chisel/i) {
    if (!quest::istaskactive(600521) && !quest::istaskcompleted(600521)) {
      quest::say("A Simple Chisel, forged true.");
      quest::assigntask(600521);
    }
    elsif (quest::istaskactive(600521)) { quest::say("A Simple Chisel. The masons wait."); }
    else { quest::say("The council smiths thank you. The forge rests a little easier tonight."); }
  }
  if ($text=~/file/i) {
    if (!quest::istaskactive(600522) && !quest::istaskcompleted(600522)) {
      quest::say("A Simple File for the armory.");
      quest::assigntask(600522);
    }
    elsif (quest::istaskactive(600522)) { quest::say("A Simple File. The armory grinds its teeth."); }
    else { quest::say("The council smiths thank you. The forge rests a little easier tonight."); }
  }
  if ($text=~/clasp/i) {
    if (!quest::istaskactive(600523) && !quest::istaskcompleted(600523)) {
      quest::say("A Simple Clasp. Make it hold.");
      quest::assigntask(600523);
    }
    elsif (quest::istaskactive(600523)) { quest::say("A Simple Clasp. The plates still rattle."); }
    else { quest::say("The council smiths thank you. The forge rests a little easier tonight."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600520)) { plugin::check_handin(\%itemcount, 58124 => 1); }
  if (quest::istaskactive(600521)) { plugin::check_handin(\%itemcount, 58090 => 1); }
  if (quest::istaskactive(600522)) { plugin::check_handin(\%itemcount, 58095 => 1); }
  if (quest::istaskactive(600523)) { plugin::check_handin(\%itemcount, 58092 => 1); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
