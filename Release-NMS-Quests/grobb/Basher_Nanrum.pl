sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Peh! What am you wanted?! I am Basher Nanrum. You $name? Heh, you look for works? Hmm, me tinks you too weakling for [job] me need done. Hmm.. You might do, mebbe, $name.");
	}
	elsif ($text=~/job/i) {
		quest::say("Me in charge of making torches for basher patrols. But Nanrum is much too mighty for such stupid job and Nanrum get idea. Dem fire bugses in da desert - dem eyes glowed. And dem don't burneded like torches. If $name getted Nanrum three fire beetle eyes me would giveded $name a shiny thingie dat you wanteded. Go ahed, $name, an' get me da eyes.");
	}
	elsif ($text=~/wheres the skeleton/i) {
		quest::say("Yeah!! Me see that bone man. He over by da Carver. He tink he butcher or sumting!!");
		#:: Spawn Grobb >> a_skeleton (52118)
		quest::spawn2(52118,0,0,-453.00,356.85,9.13,0);
	}
}

sub EVENT_ITEM {
	#:: Match three 10307 - Fire Beetle Eye
	if (plugin::check_handin(\%itemcount, 10307 => 3)) {
		quest::say("Heh heh. All da eyeballses! I didn't think ya could do it but ya did. Here is da shiny. If you gets more I always have more shinies.");
		#:: Give a random reward: 10351 - Brass Earring, 10026 - Cat's Eye Agate, 10060 - Chunk of Metal Ore, 10018 - Hematite, 10006 - Silver Earring, 10017 - Turquoise
		quest::summonitem(quest::ChooseRandom(10351, 10026, 10060, 10018, 10006, 10017));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Set factions
		quest::faction(235, 10);		#:: + Da Bashers
		quest::faction(222, -5);		#:: - Broken Skull Clan
	}
	#:: Match two 10307 - Fire Beetle Eye
	elsif (plugin::check_handin(\%itemcount, 10307 => 2)) {
	 	quest::say("Well dat be some of da eyeballses I askeded for. But I you needs ta give me three for da shiny.");
		#:: Return two 10307 - Fire Beetle Eye
		quest::summonitem(10307,2);
	}
	#:: Match one 10307 - Fire Beetle Eye
	elsif (plugin::check_handin(\%itemcount, 10307 => 1)) {
	 	quest::say("Well dat be some of da eyeballses I askeded for. But I you needs ta give me three for da shiny.");
		#:: Return one 10307 - Fire Beetle Eye
		quest::summonitem(10307,1);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
