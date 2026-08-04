sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("How are you, friend? It is a good day to be alive in Antonica! If you should happen to visit Surefall Glade, say hello to [Hager Sureshot] for me.");
	}
	elsif ($text=~/hager sureshot/i) {
		quest::say("Hager Sureshot is that know-nothing ranger in charge of the Protectors of the Pine. He thinks he can protect all of Surefall Glade. He is wrong.");
	}
}

sub EVENT_SIGNAL {
	#:: Mising signal for this dialogue
	if ($signal == 1) {
		quest::say("What kind of girly song was tha? It stank as bas as a troll's breath.");
	}
	#:: Match signal '2' from /freporte/Palana_Willin.pl
	elsif ($signal == 2) {
		quest::say("Get off the stage, lass! Can't ye see he left because ye can't carry a tune?!");
	}
	#:: Match signal '3' from /freporte/Trolon_Lightleer.pl
	elsif ($signal == 3) {
		quest::say("Yeah!! Sir Lucan is nothing more than a glory monger.");
	}
	#:: Match a signal '4' from /freporte/Tlin_Bowfright.pl
	elsif ($signal == 4) {
		quest::say("Antonius Bayle is a blithering fool.");
		#:: Send a signal '2' to East Freeport >> Tlin_Bowfright (10186) with no delay
		quest::signalwith(10186, 2, 0);
	}
	#:: Match a signal '5' from /freporte/Tlin_Bowfright.pl
	elsif ($signal == 5) {
		quest::say("All right, Tlin! I am going to smash your face in!");
		#:: Attack East Freeport >> Tlin_Bowfright (10186)
		quest::attacknpctype(10186);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
