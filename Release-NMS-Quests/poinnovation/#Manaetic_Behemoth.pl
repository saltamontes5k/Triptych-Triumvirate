# NPCID: 206074 - #Manaetic_Behemoth (targetable, awakened) - Plane of Innovation
sub EVENT_SPAWN {
  #if the targetable version has been up too long, depop him and let the dormant one return.
  quest::settimer(9,1800);
  #leash timer
  quest::settimer(4,1);
}

sub EVENT_DEATH_COMPLETE {
  #signal to Giwin to give flags.
  quest::signalwith(206038,1,1); # NPC: Giwin_Mirakon
  #let the controller bring the dormant behemoth back after a delay.
  quest::signalwith(206087,10,1); # NPC: spider_controller
}

sub EVENT_TIMER {
  if($timer == 9) {
    quest::signalwith(206087,10,1); # NPC: spider_controller
    quest::depop();
  }
  if($timer == 8) {
    quest::signalwith(206087,10,1); # NPC: spider_controller
    quest::depop();
  }
  if($timer == 4 && ($x < 1010 || $x > 1240)) {
    #leash
    $npc->GMMove(1125,0,12.5,0);
    #signal to giwin about being out of room
    quest::signalwith(206038,2,1); # NPC: Giwin_Mirakon
  }
}

sub EVENT_AGGRO {
  #fail timer
  quest::settimer(8,1800);
  quest::stoptimer(9);
}
