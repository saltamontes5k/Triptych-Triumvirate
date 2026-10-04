sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600452,600453,600454);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600452 && quest::istaskactive(600452)) { quest::say("Six lightstones, burned out. The tower still glows."); $talked = 1; last; }
      if ($tsk == 600453 && quest::istaskactive(600453)) { quest::say("Twelve guardians. The watch stands eternal - end it."); $talked = 1; last; }
      if ($tsk == 600454 && quest::istaskactive(600454)) { quest::say("The chaplain still walks. End the lordship of the tower."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600452 && !quest::istaskcompleted(600452) && !quest::istaskactive(600452)) { quest::say("The [torches] of the tower burn with stolen light. Snuff them and bring me the burned-out stones."); $talked = 1; last; }
        if ($tsk == 600453 && !quest::istaskcompleted(600453) && !quest::istaskactive(600453)) { quest::say("The [guard] of the tower died at its post and has never stood down. Break the watch."); $talked = 1; last; }
        if ($tsk == 600454 && !quest::istaskcompleted(600454) && !quest::istaskactive(600454)) { quest::say("And above them all, the [lord] of the tower - Chaplain Bloodmoon, who never rests."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("The tower stands dark and quiet for the first time in an age. You have my thanks, and the Watch's."); }
  }
  if ($text=~/torches/i) {
    if (!quest::istaskactive(600452) && !quest::istaskcompleted(600452)) {
      quest::say("Six Burned Out Lightstones, from the witchlamps and the tower lights.");
      quest::assigntask(600452);
    }
    elsif (quest::istaskactive(600452)) { quest::say("Six lightstones, burned out. The tower still glows."); }
    else { quest::say("The tower stands dark and quiet for the first time in an age. You have my thanks, and the Watch's."); }
  }
  if ($text=~/guard/i) {
    if (!quest::istaskactive(600453) && !quest::istaskcompleted(600453)) {
      quest::say("Twelve watchtower guardians, and four sets of fine bone chips for the pyre.");
      quest::assigntask(600453);
    }
    elsif (quest::istaskactive(600453)) { quest::say("Twelve guardians. The watch stands eternal - end it."); }
    else { quest::say("The tower stands dark and quiet for the first time in an age. You have my thanks, and the Watch's."); }
  }
  if ($text=~/lord/i) {
    if (!quest::istaskactive(600454) && !quest::istaskcompleted(600454)) {
      quest::say("Chaplain Bloodmoon, and ten of the never-resting. Cast the lord down.");
      quest::assigntask(600454);
    }
    elsif (quest::istaskactive(600454)) { quest::say("The chaplain still walks. End the lordship of the tower."); }
    else { quest::say("The tower stands dark and quiet for the first time in an age. You have my thanks, and the Watch's."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600452)) { plugin::check_handin(\%itemcount, 10299 => 6); }
  if (quest::istaskactive(600453)) { plugin::check_handin(\%itemcount, 97173 => 4); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
