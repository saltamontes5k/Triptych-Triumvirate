sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600473,600474,600475,600476,600477,600478,600479);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600473 && quest::istaskactive(600473)) { quest::say("Ten slashclaws. The cliffs still crawl."); $talked = 1; last; }
      if ($tsk == 600474 && quest::istaskactive(600474)) { quest::say("Eight crocs and Mossback. The river still ticks."); $talked = 1; last; }
      if ($tsk == 600475 && quest::istaskactive(600475)) { quest::say("Eight and eight. The pools still snap."); $talked = 1; last; }
      if ($tsk == 600476 && quest::istaskactive(600476)) { quest::say("Ten ghostpack wolves. The fens still howl."); $talked = 1; last; }
      if ($tsk == 600477 && quest::istaskactive(600477)) { quest::say("Ten workers, eight eggtenders. The combs still hum."); $talked = 1; last; }
      if ($tsk == 600478 && quest::istaskactive(600478)) { quest::say("Eight devils, six briars. The bones still crawl."); $talked = 1; last; }
      if ($tsk == 600479 && quest::istaskactive(600479)) { quest::say("The crusade calls. Twelve guardians, eight wanderers."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600473 && !quest::istaskcompleted(600473) && !quest::istaskactive(600473)) { quest::say("The [cliffs] first - slashclaws prowling the high passes."); $talked = 1; last; }
        if ($tsk == 600474 && !quest::istaskcompleted(600474) && !quest::istaskactive(600474)) { quest::say("And the [crocodile] that ticks - Mossback, in the darkwater. Eight crocs and the old one too."); $talked = 1; last; }
        if ($tsk == 600475 && !quest::istaskcompleted(600475) && !quest::istaskactive(600475)) { quest::say("The [pools] - snapjaws and lockjaws both."); $talked = 1; last; }
        if ($tsk == 600476 && !quest::istaskcompleted(600476) && !quest::istaskactive(600476)) { quest::say("The [fens] - the ghostpack runs them at night."); $talked = 1; last; }
        if ($tsk == 600477 && !quest::istaskcompleted(600477) && !quest::istaskactive(600477)) { quest::say("The [combs] fester - workers and eggtenders both."); $talked = 1; last; }
        if ($tsk == 600478 && !quest::istaskcompleted(600478) && !quest::istaskactive(600478)) { quest::say("By the [fallen dragon] the hedge devils gather with their briars. The old bones deserve better."); $talked = 1; last; }
        if ($tsk == 600479 && !quest::istaskcompleted(600479) && !quest::istaskactive(600479)) { quest::say("And now - the [crusade] begins! The tower dead and the moor dead both. Every blade!"); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/cliffs/i) {
    if (!quest::istaskactive(600473) && !quest::istaskcompleted(600473)) {
      quest::say("Ten slashclaws. Clear the high passes.");
      quest::assigntask(600473);
    }
    elsif (quest::istaskactive(600473)) { quest::say("Ten slashclaws. The cliffs still crawl."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/crocodile/i) {
    if (!quest::istaskactive(600474) && !quest::istaskcompleted(600474)) {
      quest::say("Eight darkwater crocodilians, and Mossback himself.");
      quest::assigntask(600474);
    }
    elsif (quest::istaskactive(600474)) { quest::say("Eight crocs and Mossback. The river still ticks."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/pools/i) {
    if (!quest::istaskactive(600475) && !quest::istaskcompleted(600475)) {
      quest::say("Eight snapjaws and eight lockjaws. Drain the pools of them.");
      quest::assigntask(600475);
    }
    elsif (quest::istaskactive(600475)) { quest::say("Eight and eight. The pools still snap."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/fens/i) {
    if (!quest::istaskactive(600476) && !quest::istaskcompleted(600476)) {
      quest::say("Ten of the ghostpack. Quiet the fens.");
      quest::assigntask(600476);
    }
    elsif (quest::istaskactive(600476)) { quest::say("Ten ghostpack wolves. The fens still howl."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/combs/i) {
    if (!quest::istaskactive(600477) && !quest::istaskcompleted(600477)) {
      quest::say("Ten worker drones and eight eggtender drones. Burn the combs.");
      quest::assigntask(600477);
    }
    elsif (quest::istaskactive(600477)) { quest::say("Ten workers, eight eggtenders. The combs still hum."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/dragon/i) {
    if (!quest::istaskactive(600478) && !quest::istaskcompleted(600478)) {
      quest::say("Eight hedge devils and six baleful briars. Give the dragon peace.");
      quest::assigntask(600478);
    }
    elsif (quest::istaskactive(600478)) { quest::say("Eight devils, six briars. The bones still crawl."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
  if ($text=~/crusade/i) {
    if (!quest::istaskactive(600479) && !quest::istaskcompleted(600479)) {
      quest::say("Twelve watchtower guardians and eight blightfire wanderers. The crusade starts with you.");
      quest::assigntask(600479);
    }
    elsif (quest::istaskactive(600479)) { quest::say("The crusade calls. Twelve guardians, eight wanderers."); }
    else { quest::say("The watch is in your debt, soldier. The roads are quieter for you, and the board thanks you."); }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
