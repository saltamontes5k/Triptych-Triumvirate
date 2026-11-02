# guildhall/player.pl - Guild Hall controller.
# Connect / zone-in: multiclass per-class signature-AA grant (once per class per
# character) plus guild-hall routing (non-guild characters are booted to the
# Guild Lobby; guild members in the static hall v0 are sent to their instance).
# Timer: portal stone alignment notice. Popup response: guild portal travel.
# (player.lua previously shadowed this file and the AA grant never ran; the
# lua's routing/portals were merged here and the shadow was removed.)

my %portals = (
    10092 => ["The Plane of Hate",186,-393,656,3],
    10094 => ["The Plane of Sky",71,539,1384,-664],
    64191 => ["Dragonscale Hills",442,-1954,3916,19],
    76000 => ["The Northern Plains of Karana",13,1209,-3685,-5],
    76001 => ["East Commonlands",22,-140,-1520,3],
    76002 => ["The Lavastorm Mountains",27,460,460,-86],
    76003 => ["Toxxulia Forest",38,-916,-1510,-33],
    76004 => ["The Greater Faydark",54,-441,-2023,4],
    76005 => ["The Dreadlands",86,9658,3047,1052],
    76006 => ["The Iceclad Ocean",110,385,5321,-664],
    76007 => ["Cobalt Scar",117,-1634,-1065,299],
    76009 => ["The Twilight Sea",170,-1028,1338,39],
    76010 => ["Stonebrunt Mountains",100,673,-4531,0],
    76011 => ["Wall of Slaughter",300,-943,13,130],
    76012 => ["Barindu, Hanging Gardens",283,209,-515,-119],
    76070 => ["The Undershore",362,-750,-1002,48],
    88735 => ["Arcstone, Isle of Spirits",369,1630,-279,5],
    88736 => ["Goru`kar Mesa",397,-85,-2050,19],
    88737 => ["your guild banner",1,1,1,1], # Not Implemented
    88738 => ["Katta Castrum",416,-2,-425,-19],
    88739 => ["The Plane of Time",219,0,110,8],
    88740 => ["Brell`s Rest",480,-23,-619,36],
);

sub _gh_route {
    my $c = shift;
    if ($uguild_id == 0) {
        quest::movepc(344, 19, -55, 5, 0); # Guild Lobby
        return;
    }
    if ($c->GetZoneInstanceVersion() == 0) {
        $c->SendToGuildHall();
    }
    quest::settimer("zone_in", 3);
}

sub _gh_grant_class_aas {
    my $c = shift;

    if($c->HasClassID(1)){ #War AA
        my $key = $c->CharacterID() . "war";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Infused by Rage and Rampage! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(6283); #Infused by Rage
            $c->IncrementAA(258); #Rampage
        }
    }

    if($c->HasClassID(2)){ #Clr AA
        my $key = $c->CharacterID() . "clr";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Twincast and Divine Arbitration! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(12652); #Twincast
            $c->IncrementAA(507); #Divine Arbitration
        }
    }

    if($c->HasClassID(3)){ #Pal AA
        my $key = $c->CharacterID() . "pal";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Divine Stun and Blessing of Life! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(188); #Divine Stun
            $c->IncrementAA(6395); #Blessing of Life
        }
    }

    if($c->HasClassID(4)){ #Rng AA
        my $key = $c->CharacterID() . "rng";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Endless Quiver, Bow Mastery, Entrap, and Auspice of the Hunter! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(205); #Endless Quiver
            $c->IncrementAA(1196); #Bow Mastery
            $c->IncrementAA(645); #Entrap
            $c->IncrementAA(1345); #Auspice of the Hunter
        }
    }

    if($c->HasClassID(5)){ #SK AA
        my $key = $c->CharacterID() . "sk";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Mortal Coil and Explosion of Spite! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(5085); #Mortal Coil
            $c->IncrementAA(13165); #Explosion of Spite
        }
    }

    if($c->HasClassID(6)){ #Dru AA
        my $key = $c->CharacterID() . "dru";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Spirit of the Wood and Paralytic Spores! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(548); #Spirit of the Wood
            $c->IncrementAA(14264); #Paralytic Spores
        }
    }

    if($c->HasClassID(7)){ #Monk AA
        my $key = $c->CharacterID() . "mnk";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Stonewall and Crippling Strike! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(810); #Stonewall
            $c->IncrementAA(1352); #Crippling Strike
        }
    }

    if($c->HasClassID(8)){ #Bard AA
        my $key = $c->CharacterID() . "brd";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Fading Memories and Dance of Blades! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(630); #Fading Memories
            $c->IncrementAA(556); #Harmonious Attack I
            $c->IncrementAA(557); #Harmonious Attack II
            $c->IncrementAA(558); #Harmonious Attack III
            $c->IncrementAA(559); #Harmonious Attack IV
            $c->IncrementAA(560); #Harmonious Attack V
            $c->IncrementAA(1110); #Dance of Blades
        }
    }

    if($c->HasClassID(9)){ #Rogue AA
        my $key = $c->CharacterID() . "rog";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Chaotic Stab and Shroud of Stealth! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(287); #Chaotic Stab
            $c->IncrementAA(605); #Shroud of Stealth
        }
    }

    if($c->HasClassID(10)){ #Shaman AA
        my $key = $c->CharacterID() . "shm";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Group Shrink and Ancestral Aid! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(10957); #Group Shrink
            $c->IncrementAA(1327); #Ancestral Aid
        }
    }

    if($c->HasClassID(11)){ #Necromancer AA
        my $key = $c->CharacterID() . "nec";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Death's Fury, Pet Affinity, and Pestilent Paralysis! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(834); #Death's Fury
            $c->IncrementAA(734); #Pet Affinity
            $c->IncrementAA(12770); #Pestilent Paralysis
        }
    }

    if($c->HasClassID(12)){ #Wizard AA
        my $key = $c->CharacterID() . "wiz";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Improved Familiar, Harvest of Druzzil, and Arcane Overkill! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(155); #Improved Familiar
            $c->IncrementAA(516); #Harvest of Druzzil
            $c->IncrementAA(5295); #Arcane Overkill
        }
    }

    if($c->HasClassID(13)){ #Mage AA
        my $key = $c->CharacterID() . "mag";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Companion's Fury, Pet Affinity, and Host in the Shell! Open up your AA window (Default V) to find it!");
            $c->IncrementAA(8201); #Companion's Fury
            $c->IncrementAA(734); #Pet Affinity
            $c->IncrementAA(8342); #Host in the Shell
        }
    }

    if($c->HasClassID(14)){ #Enchanter AA
        my $key = $c->CharacterID() . "enc";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Permanent Illusion, Project Illusion, Phantasmic Reflex, and Animation Empathy! Open up your AA window (Default V) to find them!");
            $c->IncrementAA(158); #Permanent Illusion
            $c->IncrementAA(643); #Project Illusion
            $c->IncrementAA(10551); #Phantasmic Reflex
            $c->IncrementAA(580); #Animation Empathy 1
            $c->IncrementAA(581); #Animation Empathy 2
            $c->IncrementAA(582); #Animation Empathy 3
        }
    }

    if($c->HasClassID(15)){ #Beastlord AA
        my $key = $c->CharacterID() . "bl";
        if (quest::get_data($key) == "") {
            quest::set_data($key, 1);
            $c->Message(15, "You have learned Chameleon Strike! Open up your AA window (Default V) to find it!");
            $c->IncrementAA(11080); #Chameleon Strike
        }
    }

    # Berserker (class 16): the original grant list was never filled in (it held
    # empty IncrementAA() calls that error at runtime), so no grant is made here.
    # Author the block once Berserker signature AAs are chosen.
}

sub EVENT_CONNECT {
    _gh_route($client);
    _gh_grant_class_aas($client);
}

sub EVENT_ENTERZONE {
    _gh_route($client);
    _gh_grant_class_aas($client);
}

sub EVENT_TIMER {
    if ($timer eq "zone_in") {
        quest::stoptimer("zone_in");
        my $portal_zone_item = quest::get_data("guild_portal-" . $uguild_id);
        $portal_zone_item = int($portal_zone_item || 0);
        if ($portal_zone_item > 0 && $portals{$portal_zone_item}) {
            $client->Message(13, "Zeflmin Welikanin says, The teleport stone is currently aligned to " . $portals{$portal_zone_item}[0]);
        }
    }
}

sub EVENT_POPUPRESPONSE {
    if ($portals{$popupid}) {
        my $p = $portals{$popupid};
        quest::movepc($p->[1], $p->[2], $p->[3], $p->[4], 0);
    }
}
