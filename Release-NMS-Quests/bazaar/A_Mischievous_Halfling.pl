# All player-facing output uses quest::whisper rather than quest::say. whisper goes
# only to the client that triggered the event (initiator->Message), so rolls and prizes
# are private instead of being broadcast to everyone in the Bazaar.
#
# The one exception is the jackpot tier, which additionally fires a server-wide
# announcement naming the winner and the exact mount. quest::we is a world emote --
# it reaches every player in every zone, not just the Bazaar. Type 15 is Chat::Yellow.
#
# Item names in the comments below were read from the items table; every id was
# verified to resolve. Names are listed in the same order as the ChooseRandom args.

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::whisper("Welcome to the Platinum Arcade, $name! One roll costs either " . quest::saylink("wager 20000 platinum", 1, "20,000 platinum pieces") . " or " . quest::saylink("five Triune's of Fate", 1, "five Triune's of Fate") . ". Click either option to roll, or hand me exactly 20,000 platinum. I can also " . quest::saylink("provide food and drink", 1, "provide food and drink") . " for you, free of charge.");
    }
    elsif ($text =~ /wager 20000 platinum/i) {
        if ($client->TakeMoneyFromPP(20000000, 1)) {
            quest::whisper("Twenty thousand platinum accepted. Rolling the dice!");
            RollCasinoPrize();
        }
        else {
            quest::whisper("You need 20,000 platinum pieces on hand for a roll.");
        }
    }
    elsif ($text =~ /five Triune's of Fate/i) {
        if (plugin::SpendEOM($client, 5)) {
            quest::whisper("Five Triune's accepted. Rolling the dice!");
            RollCasinoPrize();
        }
        else {
            quest::whisper("You need five Triune's of Fate for a roll.");
        }
    }
    elsif ($text =~ /provide food and drink/i) {
        # Free and repeatable on purpose -- both items are price 0, so there is nothing
        # to vendor them for and no plat can be farmed from this. stacksize is 100 for
        # both, so a full stack is the most a single inventory slot can hold.
        #   25866  Legends' Blessing (food)   <-- races 65533: everyone EXCEPT Barbarians
        #   25865  Heroes' Blessing  (drink)  <-- races 65535: all races
        quest::summonfixeditem(25866, 100);
        quest::summonfixeditem(25865, 100);
        quest::whisper("Help yourself, $name -- a full stack of each. Come back any time you run low.");
    }
}

sub EVENT_ITEM {
    my $cash = ($platinum * 1000) + ($gold * 100) + ($silver * 10) + $copper;

    if ($cash == 20000000 && scalar(keys %itemcount) == 0) {
        quest::whisper("Twenty thousand platinum accepted. Rolling the dice!");
        RollCasinoPrize();
    }
    else {
        quest::whisper("One roll costs exactly 20,000 platinum, or hail me to wager five Triune's of Fate.");
        quest::givecash($copper, $silver, $gold, $platinum);
        plugin::return_items(\%itemcount);
    }
}

sub RollCasinoPrize {
    my $roll = int(rand(100));

    # The 9% the Rank III tier needed was reclaimed from this food tier (was 25%) so that
    # every tier from "Nicely done" upward keeps its original boundary and weight.
    if ($roll < 16) {
        # 16% -- food consolation, awarded as a stack of 3.
        # The second summonfixeditem arg is charges; for a stackable item SummonItem
        # passes it straight through as the stack size (inventory.cpp, "just use charges
        # as passed"). All six are stackable with stacksize 20, so 3 is safe.
        #   36995  Quarken Xired's Timeless Trail Rations
        #   57825  Rilgor's Prime Number Ribs
        #   64489  Lunanyn's Feast
        #   57819  Solferino Sublime
        #   57818  Hazenfranze
        #   37538  Oriaas Nostrum
        quest::summonfixeditem(quest::ChooseRandom(36995, 57825, 64489, 57819, 57818, 37538), 3);
        quest::whisper("Better luck next time! Here's some food for your troubles!");
    }
    elsif ($roll < 41) {
        # 25% -- potion consolation
        #   56942  Distillate of Celestial Healing
        #   56940  Distillate of Clarity
        #   56938  Distillate of Comprehension
        #   56934  Distillate of Antidote
        #   56935  Distillate of Immunization
        #   56944  Distillate of Replenishment
        #   56937  Distillate of Skinspikes
        quest::summonfixeditem(quest::ChooseRandom(56942, 56940, 56938, 56934, 56935, 56944, 56937));
        quest::whisper("Better luck next time! Here's a potion for your troubles!");
    }
    elsif ($roll < 62) {
        # 21% -- Rank I bottles: SPA 337 XP modifier at 10, 2400 ticks. The common XP prize.
        #   41961  Bottle of Adventure I
        #   48083  Bottle of Shared Adventure I
        quest::summonfixeditem(quest::ChooseRandom(41961, 48083));
        quest::whisper("Let the experience flow!");
    }
    elsif ($roll < 71) {
        # 9% -- Rank III bottles: same SPA 337 / 2400 ticks, but base value 50 instead of 10.
        # These two keep the Rank I flags (stackable, NO TRADE, permanent); the other
        # two "Bottle of Adventure III" ids (51783, 51790) are a different, non-stackable line.
        #   43494  Bottle of Adventure III
        #   48085  Bottle of Shared Adventure III
        quest::summonfixeditem(quest::ChooseRandom(43494, 48085));
        quest::whisper("Let the experience flow!");
    }
    elsif ($roll < 82) {
        # 11% -- Petamorph wands (reshape your pet's appearance)
        #   67923  Petamorph Wand - Amethyst Crystalline Trichordont
        #   56052  Petamorph Wand - Aviak
        #   61036  Petamorph Wand - Brownie
        #   62774  Petamorph Wand - Cliknar
        #   66783  Petamorph Wand - Domain Prowler
        #   64711  Petamorph Wand - Gnomework
        #   66431  Petamorph Wand - Goo
        #   66449  Petamorph Wand - Kirin
        #   67953  Petamorph Wand - Mad Jester
        #   67883  Petamorph Wand - Nightmare Skull
        #   52193  Petamorph Wand - Scarecrow
        #   66598  Petamorph Wand - Snow Spider
        #   61979  Petamorph Wand - Sporali
        #   67145  Petamorph Wand - Steamwork Soldier
        #   66564  Petamorph Wand - Worg
        quest::summonfixeditem(quest::ChooseRandom(67923, 56052, 61036, 62774, 66783, 64711, 66431, 66449, 67953, 67883, 52193, 66598, 61979, 67145, 66564));
        quest::whisper("Nicely done! Congratulations, $name!");
    }
    elsif ($roll < 88) {
        # 6% -- player illusion masks and visages
        #   37954  Mask of the Grumpy Goblin
        #   67008  Froglok Stone
        #   43993  Visage of Bragnar Noox
        #   37999  Mask of the Mighty Minotaur
        #   40638  Visage of the Ice Golem
        #   50872  Visage of the War Pirate
        #   40714  Visage of the Siren Enticer
        #   40686  Visage of the Stone Gargoyle
        #   50854  Visage of the Dark Arachnids
        #   40656  Visage of the Brownie Noble
        #   31861  Da Oogly Stick
        quest::summonfixeditem(quest::ChooseRandom(37954, 67008, 43993, 37999, 40638, 50872, 40714, 40686, 50854, 40656, 31861));
        quest::whisper("Epic illusion prize! Congratulations, $name!");
    }
    elsif ($roll < 91) {
        # 3% -- standard mounts
        #   59508  Giant Black Drum
        #   59513  Giant Green Drum
        #   43970  Onyx Hydra Saddle
        #   57798  Golden Wurm Saddle
        #   54983  Frost Wurm Saddle
        #   60437  Forest Jaguar Saddle
        #   52098  Fleshless Rotdog Saddle
        #   64560  Tiger Raptor Saddle
        #   54934  War Bear Saddle
        #   66317  White Wolf Saddle
        quest::summonfixeditem(quest::ChooseRandom(59508, 59513, 43970, 57798, 54983, 60437, 52098, 64560, 54934, 66317));
        quest::whisper("Epic mount prize! Congratulations, $name!");
    }
    elsif ($roll < 93) {
        # 2% -- 52024  Urthron's Ultimate Unattuner
        quest::summonfixeditem(52024);
        quest::whisper("Epic unattuner prize! Congratulations, $name!");
    }
    elsif ($roll < 96) {
        # 3% -- rare beast mounts. All verified all-class / all-race, no level requirement.
        #   17722  Bridle of the Unicorn
        #   17721  Bridle of the Nightmare
        #   57368  Komodo Dragon Saddle
        #   43969  Jade Hydra Saddle
        #   62787  Desert Tarantula Saddle
        #   60945  Firescale Wrulon Saddle
        #   64187  Prismatic Selyrah Saddle
        #   72274  Umbral Selyrah Saddle
        #   66397  Regal Worg Saddle
        #   54982  Ember Wurm Saddle
        #   61948  Shadow Wurm Saddle
        #   72276  Ornate Flying Carpet
        #   40777  Bridle of the Highland Lion
        #   40601  Bridle of the Snow Leopard
        #   40776  Bridle of King Kalakor
        quest::summonfixeditem(quest::ChooseRandom(17722, 17721, 57368, 43969, 62787, 60945, 64187, 72274, 66397, 54982, 61948, 72276, 40777, 40601, 40776));
        quest::whisper("Rare mount prize! Congratulations, $name!");
    }
    elsif ($roll < 99) {
        # 3% -- top prize: the flying Skystrider line plus the armored pegasus and Ethernere wurm.
        # Roll into a variable first so the announcement can name the exact mount won.
        #   66319  Empowered Dragonscale Skystrider Saddle
        #   66315  Dragonscale Skystrider Saddle
        #   66314  Celestial Skystrider Saddle
        #   66312  Blazing Skystrider Saddle
        #   66308  Onyx Skystrider Saddle
        #   66309  Parade Armored Onyx Skystrider Saddle
        #   66307  Battle Armored Pegasus Saddle
        #   66311  Dreadmare Saddle
        #   66305  Pegasus Saddle
        #   85370  Ethernere Wurm Saddle
        my $prize_id = quest::ChooseRandom(66319, 66315, 66314, 66312, 66308, 66309, 66307, 66311, 66305, 85370);
        quest::summonfixeditem($prize_id);
        quest::whisper("JACKPOT! An ultra-rare flying mount! Congratulations, $name!");
        quest::we(15, "[Platinum Arcade] $name just hit the JACKPOT and won a " . quest::getitemname($prize_id) . "!");
    }
    else {
        # 1% -- roll of exactly 99. Same food list and stack of 3 as the 16% tier above.
        quest::summonfixeditem(quest::ChooseRandom(36995, 57825, 64489, 57819, 57818, 37538), 3);
        quest::whisper("Better luck next time! Here's some food for your troubles!");
    }
}
