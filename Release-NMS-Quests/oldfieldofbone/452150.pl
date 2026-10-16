# Phara Dar (452150) -- "The Grand Illusion" (raspersrealm themeKunark,
# FoS_T_10..FoS_T_14). Bring the remains of the ancient iksar -- the Skull
# of Commander Koth who holds the Kaesora road and an Iksar Ribcage from
# his advisors -- and Phara Dar weaves them into the Bone Mask of the
# Ancient Iksar (80061): the theme illusion clicky whose positive faction
# buff makes you non-KoS to nearly everything in Field of Scale while
# worn. Also the path to the Warmly/Ally tiers of Tynoc's wares.
sub EVENT_SAY {
    if ($text =~ /hail/i) {
        if ($client->CountItem(80061) > 0) {
            quest::say("Wear the ancients' face well. Behind that mask the sarnak see only an old ghost of the ages -- walk their camps freely.");
        } elsif ($client->CountItem(17382) > 0 && $client->CountItem(17381) > 0) {
            quest::say("You carry the old bones. Give them to me, and I will weave you the grand illusion.");
        } else {
            quest::say("The discordlings promised the sarnak an iksar empire, and the sarnak desecrate the bones of my people to hold it. Bring me the Skull of Commander Koth from the Kaesora road, and an Iksar Ribcage from the advisors who serve him, and I will show you the ancients' face.");
        }
    }
}

sub EVENT_ITEM {
    if (plugin::check_handin(\%itemcount, 17382 => 1, 17381 => 1)) {
        quest::summonitem(80061);    # Bone Mask of the Ancient Iksar
        quest::say("It is done. Skull and ribcage knit together by dragonfire and memory -- wear it, and the age of the ancients wears you. The Herald of Scale will know your deeds as your legend grows in this field.");
        $client->Message(15, "Phara Dar grants you The Grand Illusion.");
        quest::faction(1224, 300);   # Tynoc, Herald of Scale
        quest::exp(500000);
    } else {
        plugin::return_items(\%itemcount);
    }
}
