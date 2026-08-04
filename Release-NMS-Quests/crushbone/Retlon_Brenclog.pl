sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Oh my word!! A rescuer!! Hurry! [Get me out] of these chains!! Go find the orc who has the keys!");
	}
	elsif ($text=~/get me out/i) {
		quest::say("I am from Ak'Anon! I must return a [spellbook] to the Eldritch Collective!");
	}
	elsif ($text=~/spellbook/i) {
		quest::say("What?! I am stuck here and you are worried about a spellbook?! Forget that! Just get the keys to my shackles from one of the orcs! HURRY!");
	}
}

sub EVENT_ITEM {
	#:: Match a 20015 - Shackle Key 15
	if (plugin::check_handin(\%itemcount, 20015 => 1)) {
		quest::say("Good work!! I shall be on my way. Farewell my friend!!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(245, 1); 		#:: + Eldritch Collective
		quest::faction(333, 1); 		#:: + King Ak'Anon
		quest::faction(255, 1); 		#:: + Gem Choppers
		quest::faction(239, -2); 		#:: - The Dead
		#:: Grant a moderate amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 600 to 800cp
		my %cash = plugin::RandomCash(600,800);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Create a timer 'depop' that triggers every 240 seconds (4 minutes)
		quest::settimer("depop", 240);
	}
	#:: Match a 18887 - Sealed Letter (Note to Retlon Brenclog)
	elsif (plugin::check_handin(\%itemcount, 18887 => 1)) {
		quest::say("Ah! A letter from my brother! Mmm... no... no I don't have Tergon's spellbook. The orc's prophet took it and then they locked me in chains! Now why don't you go do something useful and get me key number 15!!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(245, 1); 		#:: + Eldritch Collective
		quest::faction(333, 1); 		#:: + King Ak'Anon
		quest::faction(255, 1); 		#:: + Gem Choppers
		quest::faction(239, -2);	 	#:: - The Dead
		#:: Grant a moderate amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 600 to 800cp
		my %cash = plugin::RandomCash(600,800);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_TIMER {
	#:: Match the timer 'depop'
	if ($timer eq "depop") {
		#:: Stop the timer 'depop'
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
}
