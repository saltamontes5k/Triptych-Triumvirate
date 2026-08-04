sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Removed mention of 'Also, remember to ask me later about a special Bardic Weapon' for Bard Epic 1.5
		quest::say("Good day to you. I am Walthin Fireweaver of the League of Antonican Bards. My friend Cyrissa and I are here while we deal in [Lambent stones] with the followers of Solusek Ro. If you are interested, Cyrissa and I also deal in [Lambent Armor] – the perfect armor for a Bard of standing.");
	}
	elsif ($text=~/lambent armor/i) {
		quest::say("Lambent armor is custom-crafted armor, made especially for bards. It is forged by the MeadowGreen brothers and then enchanted by the followers of Solusek Ro. If you are interested, I can tell you about [lambent gauntlets], [lambent greaves] and [lambent boots]. Cryssia can tell you about other lambent armor.");
	}
	elsif ($text=~/lambent stone/i) {
		quest::say("'Lambent stones are gemstones of great power. They are midnight blue in color - if you want more information on them you should ask Genni.");
	}
	elsif ($text=~/boots/i) {
		quest::say("'Lambent boots are the boots of choice for most bards. If you can bring me firewalker boots from a Solusek Mage and the middle portion of the rune of the One Eye from Froon then I will give you a pair of lambent boots. Oh, I almost forgot! I will need a lambent sapphire as well.");
	}
	elsif ($text=~/gauntlets/i) {
		quest::say("Lambent gauntlets are exceptionally well made gauntlets. If you are interested, I will give you a pair, but you will have to bring me the following items that I need for a trade with the followers of Solusek Ro. I need shin gauntlets from a froglok knight and black silk gloves from Castle Mistmoore. You will also need to talk to Genni about getting me a lambent star ruby. Bring me these items and you will earn lambent gauntlets.");
	}
	elsif ($text=~/greaves/i) {
		quest::say("There are no finer leggings for a bard than lambent greaves. Collect for me two pairs of lesser greaves and I will give you some. Bring me icy greaves from the caverns of Permafrost and shin greaves from a ghoul knight, as well as a lambent fire opal and I will bestow a pair of lambent greaves upon you.");
	}
}

sub EVENT_ITEM {
    # Match a 2318 - Firewalker Boots, a 10119 - Lambent Sapphire, and a 10561 - Rune of the One Eye
    if (plugin::check_handin(\%itemcount, 2318 => 1, 10119 => 1, 10561 => 1)) {
        quest::say("'Quality boots for a quality bard. Well done, $name.");
        quest::summonitem(4159); # Lambent Boots
        quest::ding();
        quest::faction(415, 10); # + Temple of Solusek Ro
        quest::faction(416, -1); # - Shadowed Men
        quest::exp(1000);
    }
    # Match a 2319 - Black Silk Gloves, a 10117 - Lambent Star Ruby, and a 4114 - Shin Gauntlets
    elsif (plugin::check_handin(\%itemcount, 2319 => 1, 10117 => 1, 4114 => 1)) {
        quest::say("Well done, $name, you have justly earned your pair of lambent gauntlets.");
        quest::summonitem(4157); # Lambent Gauntlets
        quest::ding();
        quest::faction(415, 10); # + Temple of Solusek Ro
        quest::faction(416, -1); # - Shadowed Men
        quest::exp(1000);
    }
    # Match a 4115 - Icy Greaves, a 10128 - Lambent Fire Opal, and a 4116 - Shin Greaves
    elsif (plugin::check_handin(\%itemcount, 4115 => 1, 10128 => 1, 4116 => 1)) {
        quest::say("I always knew that you would earn these lambent greaves, $name, you just had that look about you. Well done!");
        quest::summonitem(4158); # Lambent Greaves
        quest::ding();
        quest::faction(415, 10); # + Temple of Solusek Ro
        quest::faction(416, -1); # - Shadowed Men
        quest::exp(1000);
    }

    plugin::return_items(\%itemcount);
}

