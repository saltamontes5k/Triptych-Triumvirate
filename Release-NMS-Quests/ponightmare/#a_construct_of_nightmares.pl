sub EVENT_DEATH_COMPLETE {
    quest::spawn2(204067,0,0,$x,$y,$z,0);
    quest::signalwith(204016,8,1); # NPC: Thelin_Poxbourne
}