sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Match if faction is indifferent or better
		if ($faction <= 5) {
			quest::say("I am Tv`ysa, guardian of the [Concordance of Research].");
		}
		else {
			quest::say("Oh look, a talking lump of refuse. How novel!");
		}
	}
	elsif ($text=~/concordance of research/i) {
		#:: Match if faction is indifferent or better
		if ($faction <= 5) {
			quest::say("The 'Concordance of Research' is an aid to those who follow the path of academia. It, and its sister books, 'Runes and Research', volumes I and II, help those who are [interested] in researching spells.");
		}
		else {
			quest::say("I didn't know Slime could speak common. Go back to the sewer before I lose my temper.");
		}
	}
	elsif ($text=~/interested/i) {
		#:: Match if faction is indifferent or better
		if ($faction <= 5) {
			quest::say("I have several copies of each book. If you want a copy of 'Runes and Research', volume I or II, bring me a lightstone and I will give you whichever book I have more of at the moment. Bring me a greater lightstone, and I will give you a copy of the 'Concordance of Research.");
		}
		else {
			quest::say("After all the things you've done... the things you believe in... leave my shop!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 10300 - Lightstone
	if (plugin::check_handin(\%itemcount, 10300 => 1)) {
		#:: Match if faction is indifferent or better
		if ($faction <= 5) {
			quest::say("A lightstone? Thank you very much. Here is a copy of 'Runes and Research' for you.");
			#:: Give a random reward: 18175 - Runes and Research Volume I, or 18176 - Runes and Research Volume II
			quest::summonitem(quest::ChooseRandom(18175, 18176));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(236, 10);	#:: + Dark Bargainers
			quest::faction(370, 1);		#:: + Dreadguard Outer
			quest::faction(334, 1);		#:: + Dreadguard Inner
			#:: Grant a large amount of experience
			quest::exp(10000);
		}
		else {
			quest::say("After all the things you've done... the things you believe in... leave my shop!");
			#:: Return a 10300 - Lightstone
			quest::summonitem(10300);
		}
	}
	#:: Match a 10400 - Greater Lightstone
	elsif (plugin::check_handin(\%itemcount, 10400 => 1)) {
		#:: Match if faction is indifferent or better
		if ($faction <= 5) {
			quest::say("A greater lightstone? Thank you very much. Here is a 'Concordance of Research' for you.");
			#:: Give a 17504 - Concordance of Research
			quest::summonitem(17504);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(236, 10);	#:: + Dark Bargainers
			quest::faction(370, 1);		#:: + Dreadguard Outer
			quest::faction(334, 1);		#:: + Dreadguard Inner
			#:: Grant a large amount of experience
			quest::exp(20000);
		}
		else {
			quest::say("After all the things you've done... the things you believe in... leave my shop!");
			#:: Return a 10400 - Greater Lightstone
			quest::summonitem(10400);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
