sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Hello there, $name. Please watch where you are stepping when you're out in the field.  Nothing is more frustrating than having some fine jumjum ruined by our own careless feet. That reminds me, [Deputy Tagil] still owes us for that jumjum he stomped on the other day!");
	}
	elsif ($text=~/deputy tagil/i) {
		quest::say("Deputy Tagil is a fine young halfling who serves the vale well. But the other day, chasing that dirty Nillipuss, he trampled some fresh Jumjum.  He promised to make amends but it must have slipped his mind.  Please take this note to him as a friendly reminder.");
		#:: Give a 18013 - Note
		quest::summonitem(18013); 
	}
}

sub EVENT_ITEM {
	#:: Match a 13240 - Deputy Tagil's Payment
	if (plugin::check_handin(\%itemcount, 13240 => 1)) {
		quest::say("I knew that Deputy Tagil had simply forgotten. He really is a good young halfling. Here, take this as a small payment for your time.");
		#:: Give a random reward: 13977 - Carrot, 13100 - Fishing Pole, 14014 - Potion of Wisdom, 13083 - Pine Needles
		quest::summonitem(quest::ChooseRandom(13977,13100,14014,13083));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 100 to 500cp
		my %cash = plugin::RandomCash(100,500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(355, 1);		#:: + Storm Reapers
		quest::faction(286, 1);		#:: + Mayor Gubbin
		quest::faction(292, 1);		#:: + Merchants of Rivervale
		quest::faction(324, -1);	#:: - Unkempt Druids
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
