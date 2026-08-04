sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("How are you? Welcome to the Academy of Arcane Science. Please feel free to roam. May knowledge be your goal. Be you a [fellow scientist] or visitor, I am sure you will find whatever you seek.");
	}
	elsif ($text=~/fellow scientist/i) {
		quest::say("That is good. I hope you can handle the knowledge of arcane science. Some have gone mad conducting research. Such a person is [Lydl Mastat].");
	}	
	elsif ($text=~/lydl mastat/i) {
		quest::say("Lydl Mastat is nothing more than a young apprentice of mine. He went mad working on a formula for deep water breathing. He now roams the outskirts of Freeport boasting of power he does not have. Someone should [teach Lydl a lesson].");
	}	
	elsif ($text=~/teach Lydl a lesson/i) {
		quest::say("Then go. He appears near the gates of Freeport from time to time. He is not powerful, but he has a secret. Nothing save magic can harm him. This was the result of an experimental potion he drank. Slay him and return his locked spellbook to me.");
	}	
}

sub EVENT_ITEM {
	#:: Match a 13863 - A Locked Book
	if (plugin::check_handin(\%itemcount, 13863 => 1)) {
		quest::say("It is a shame we had to take such actions. I mourn for the sanity of Lydl. I cheer for the addition of such a fine wizard as yourself. I found this while rummaging through my vault. Take it as thanks. It is not much.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220,10); 	#:: + Arcane Scientists
		quest::faction(281,2); 		#:: + Knights of Truth
		quest::faction(330,-1); 	#:: - Freeport Militia
		quest::faction(296,-1); 	#:: - Opal Darkbriar
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 1 to 10cp
		my %cash = plugin::RandomCash(1,10);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
