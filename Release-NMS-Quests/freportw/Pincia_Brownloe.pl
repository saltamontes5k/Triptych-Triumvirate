sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to Brownloe Bakery. Please try our muffins. One taste and you will yearn for no other. Nothing compares to a Brownloe Muffin!");
	}
}

sub EVENT_SIGNAL { 
	#:: Match a signal "1" from /freportw/Pandos_Flintside.pl
	if ($signal == 1) {
		quest::say("You are in luck! I have a fresh batch that just came out of the oven!");
		#:: Send a signal "1" to West Freeport >> Pandos_Flintside (9057) with a 10 second delay
		quest::signalwith(9057, 1, 10);
	}
	#:: Match a signal "2" from /freportw/Pandos_Flintside.pl
	elsif ($signal == 2) {
		quest::say("Farewell, then. I will make sure to have them ready for you tomorrow!");
		#:: Send a signal "2" to West Freeport >> Pandos_Flintside (9057) with a 10 second delay
		quest::signalwith(9057, 2, 10);
	}	
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
