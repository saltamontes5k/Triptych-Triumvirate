sub EVENT_SPAWN {
    quest::settimer(1, 1200);
}

sub EVENT_SAY {
    if ($text=~/hail/i) {        
        if (quest::get_data($quarmkey) eq "") {
            quest::set_data($quarmkey, 1);
            quest::say("I have been watching you... since the great before...");
            quest::emote("An Observer beams a smile at you.");
            quest::say("Did you know? Your great deeds are [" . quest::saylink("fabled") . "] even among my kind.");
        } else {
            quest::say("Did you know? Your great deeds are [" . quest::saylink("fabled") . "] even among my kind.");
        }
    }

    if ($text =~ /fabled/i) {
        plugin::SetSubflag($client, 'GoD', 'Saryrn');
        quest::say("Indeed. I remember one particularly harrowing battle...");
    }
}

sub EVENT_TIMER {
    quest::depop();
}
