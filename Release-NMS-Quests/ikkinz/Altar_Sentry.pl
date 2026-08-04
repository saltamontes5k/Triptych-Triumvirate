#Ikkinz Raid #4: Chambers of Destruction 
sub EVENT_SPAWN {
	quest::setnexthpevent(80);
}

sub EVENT_DEATH_COMPLETE {
	quest::spawn2(294628,0,0,$x,$y,$z,$h); # NPC: a_pile_of_bones
	quest::ze(0,"The stone worker crumbles to the ground, its energy drained.");
  	quest::signalwith(294614, 1, 0); # NPC: #Trigger_Ikkinz_4
}

sub EVENT_HP {
  if($hpevent == 80) {
    $npc->WipeHateList();
    quest::setnexthpevent(60);
    quest::emote("changes target");
  }
  if($hpevent == 60) {
    $npc->WipeHateList();
    quest::setnexthpevent(40);
    quest::emote("changes target");
  }
  if($hpevent == 40) {
    $npc->WipeHateList();
    quest::setnexthpevent(20);
    quest::emote("changes target");
  }
  if($hpevent == 20) {
    $npc->WipeHateList();
  }
}
