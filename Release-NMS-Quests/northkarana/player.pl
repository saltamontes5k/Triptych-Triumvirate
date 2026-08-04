#BeginFile: northkarana\player.pl
#Quest file for North Karana: Paladin message during Necromancer Epic 1.5 (Soulwhisper)

sub EVENT_LOOT {
    if (($looted_id == 14344) && 
        plugin::check_hasitem($client, 26896) && 
        plugin::check_hasitem($client, 11430) && 
        plugin::check_hasitem($client, 22892)) { # All 4 Paladin Heads
        $client->Message(15, "With his last breath, the paladin says, 'You are too late. The last paladin has fled to Natimbi with the staff and is on his way to destroy it!'");
    }
    
    if (plugin::HasClassName($client, "Ranger") && $looted_id == 62604) {
        if (defined $qglobals{ranger_epic15_pre} && $qglobals{ranger_epic15_pre} ne "8") {
            return 1;
        } else {
            return 0;
        }
    }
}

#EndFile: northkarana\player.pl
