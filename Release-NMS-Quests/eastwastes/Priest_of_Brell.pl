sub EVENT_SIGNAL {
  quest::debug("Priest of Brell received signal - " . $signal);
  $npc->ResumeWandering();
  if ($signal == 1){
    # Fall into formation
    quest::modifynpcstat("runspeed", 2.25);
  } elsif ($signal == 2){
    # Begin march to fort
    quest::modifynpcstat("runspeed", 1.25);
  } elsif ($signal == 3){
    # Charge into battle
    quest::modifynpcstat("runspeed", 2.25);
  }
}

sub EVENT_WAYPOINT_ARRIVE {
  # Pause our wandering at each of the waypoints
  $npc->PauseWandering(0);

  if ($wp==3) {
    # Arrived at final waypoint.  Stop navigation
    quest::settimer(9,300);
  }
}

sub EVENT_TIMER {
  if($timer == 9) {
    quest::stoptimer(9);
    quest::depopall(116541);
  }
}
