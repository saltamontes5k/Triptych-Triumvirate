sub EVENT_SPAWN {
    quest::ze(1, "You hear squealing voices of Centi echo through the dark hallways. Something must have them frightened. You find yourself wondering what could possibly scare the servants of the Akheva. Do you really want to know?");
    #quest::settimer("depop", 30 * 60);
}

sub EVENT_SLAY {
    quest::spawn2(179136, 0, 0, $x - 10, $y, $z, $h);
    quest::spawn2(179136, 0, 0, $x + 10, $y, $z, $h);
    quest::spawn2(179136, 0, 0, $x, $y - 10, $z, $h);
    quest::spawn2(179136, 0, 0, $x, $y + 10, $z, $h);
}

sub EVENT_TIMER {
    if ($timer eq "depop") {
        quest::stoptimer($timer);
        quest::depop();
    }
}

sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}
