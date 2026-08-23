sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What are you doing in here? I requested no room service. Now leave, quickly, before [Mistress Anna] comes!");
	}
	elsif ($text=~/mistress anna/i) {
		quest::say("Mistress Anna is my lover. She will wed me as soon as she is through mourning the loss of her ex-lover. Until then, I shall continue to keep her well. She assures me she will be over it soon. I am sure she loves me. She meets with me often. 'At 9 in 6,' she always says.");
	}
	elsif ($text=~/princess lenya thex/i) {
		quest::say("What was that about Princess Lenya? You know her? I feel sorry for her. I wish I had the courage to help her. I made the key for her special shackles. Maybe you can rescue her. Tell you what, I have always wanted to venture to Qeynos to buy a silk evening tunic for Mistress Anna. You go and get me it and I shall give you the key to Princess Lenya's shackles.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13352 -  Silk Evening Tunic
	if (plugin::check_handin(\%itemcount, 13352 => 1)) {
		quest::say("Ahh!! The silk evening tunic. Mistress Anna will look stunning in this. Here is the key to Princess Lenya's cell. Good luck, hero!");
		#:: Give item 20008 - Brass Key
		quest::summonitem(20008);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(331, 10); 		#:: + Merchants of Highpass
		quest::faction(332, 10); 		#:: + Highpass Guards
		quest::faction(329, 10); 		#:: + Carson McCabe
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
