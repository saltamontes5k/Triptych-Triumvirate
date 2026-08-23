sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, merry gentlefolk! If you enjoy the music, please feel free to cross my palm with gold.");
	}
}

sub EVENT_ITEM {
	#:: Match 200 copper coins - 2gp
	if (plugin::takeCoin(0, 0, 2, 0)) {
		quest::say("Rat spittle! Busted another string! You seem like a good music loving citizen, could you please run to the Wind Spirit's Song and grab me a fresh set of lute strings?");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 2);			#:: + League of Antonican Bards
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(262, 1);			#:: + Guards of Qeynos
		quest::faction(304, -1);		#:: - Ring of Scale
		quest::faction(285, -1);		#:: - Mayong Mistmoore
	}
	#:: Match 13709 - Lute Strings
	if (plugin::check_handin(\%itemcount, 13709 => 1)) {
#::		2007 Release Era Addition to Quest
#::		my $random_lute_strings_message = int(rand(5)) + 1;
#::		if ($random_lute_strings_message == 4) {
#::			quest::say("Many thanks, merry gentlefolk! Let me cross your palm in gratitude for your kindness. Hmmmm where did my lucky coin go?");
#::			#:: Give a 13710 - Etched Silver Coin
#::			quest::summonitem(13710);
#::		} else {
			quest::say("Many thanks, merry gentlefolk! Let me cross your palm in gratitude for your kindness.");
#:: 		}
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 2);			#:: + League of Antonican Bards
		quest::faction(281, 1);			#:: + Knights of Truth
		quest::faction(262, 1); 		#:: + Guards of Qeynos
		quest::faction(304, -1);		#:: - Ring of Scale
		quest::faction(285, -1);		#:: - Mayong Mistmoore
		#:: Grant a moderate amount of experience
		quest::exp(5000);
		#:: Grant between 900 and 2000 copper coins - 9gp to 2pp
		%cash = plugin::RandomCash(900,2000);
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum}); 
	}
#::	#:: 2007 era quest addition Match a 13710 - Etched Silver Coin
#::	if (plugin::check_handin(\%itemcount, 13710 => 1)) {
#::		quest::say("'My lucky coin! How did it get in there? Well, never mind that. You are an honest person and although honesty is its own reward, I feel obligated to return the favor. Take this to Dionna if you enjoy music. Farewell friend!");
#::		#:: Give a 13708 - Note from Fabian
#::		quest::summonitem(13708);
#::		#:: Ding!
#::		quest::ding();
#::		#:: Set factions
#::		quest::faction(284,5);			#:: + League of Antonican Bards
#::		quest::faction(281,5);			#:: + Knights of Truth
#::		quest::faction(262,5);			#:: + Guards of Qeynos
#::		quest::faction(304,-5);			#:: - Ring of Scale
#::		quest::faction(285,-5);			#:: - Mayong Mistmoore
#::		#:: Give a moderate amount of experience
#::		quest::exp(5000);
#::		#:: Grant between 900 and 2000 copper coins - 9gp to 2pp
#::		%cash = plugin::RandomCash(900,2000);
#::		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum}); 
#::	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
