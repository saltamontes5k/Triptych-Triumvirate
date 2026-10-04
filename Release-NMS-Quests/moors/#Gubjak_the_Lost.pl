sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600446,600447);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600446 && quest::istaskactive(600446)) { quest::say("Five bone shards, mon. De dead be waitin'."); $talked = 1; last; }
      if ($tsk == 600447 && quest::istaskactive(600447)) { quest::say("Twelve thralls still walkin'. Lay dem down."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600446 && !quest::istaskcompleted(600446) && !quest::istaskactive(600446)) { quest::say("De [spirits] here be restless for want of bone. Bring me shards from de blightfire dead and Gubjak will call dem proper."); $talked = 1; last; }
        if ($tsk == 600447 && !quest::istaskcompleted(600447) && !quest::istaskactive(600447)) { quest::say("De [thralls] walk dat should sleep. Lay dem down, mon."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("De dead sleep quiet now. Gubjak thanks you, mon, and de moors breathe easier."); }
  }
  if ($text=~/spirits/i) {
    if (!quest::istaskactive(600446) && !quest::istaskcompleted(600446)) {
      quest::say("Five Blightfire Bone Shards, from de witchlamps and de treants and de crocs. Den Gubjak calls.");
      quest::assigntask(600446);
    }
    elsif (quest::istaskactive(600446)) { quest::say("Five bone shards, mon. De dead be waitin'."); }
    else { quest::say("De dead sleep quiet now. Gubjak thanks you, mon, and de moors breathe easier."); }
  }
  if ($text=~/rest/i) {
    if (!quest::istaskactive(600447) && !quest::istaskcompleted(600447)) {
      quest::say("Twelve thralls. Lay dem to rest and come back to Gubjak.");
      quest::assigntask(600447);
    }
    elsif (quest::istaskactive(600447)) { quest::say("Twelve thralls still walkin'. Lay dem down."); }
    else { quest::say("De dead sleep quiet now. Gubjak thanks you, mon, and de moors breathe easier."); }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600446)) { plugin::check_handin(\%itemcount, 46286 => 5); }
  plugin::return_items(\%itemcount);
  plugin::return_items(\%itemcount);
}
