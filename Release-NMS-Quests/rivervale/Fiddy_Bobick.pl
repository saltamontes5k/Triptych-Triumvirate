sub EVENT_WAYPOINT_ARRIVE {
	if ($wp == 6) {
		quest::say("When will Wickystick send help?!");
	}
}

sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Ahoy, mate!! The name's Fiddy Bobick! Perhaps you've heard of me.. the greatest halfling to sail the seas of Norrath? I have been to the North, South, East and West...and thank Prexus, I have survived it all!  Why I have returned to this little hollow is a wonder to me. Obviously, the salty air finally got to my brain!");
	}
	elsif ($text=~/lanena/i) {
		quest::say("Well, it's about blasted time!  The ship was about to sink.  Wickystick finally managed to send the troops in!  The problem, mate, is piranha !!  What?!!  That's what I said.  Piranha!  The lake is infested with the little buggers.  More and more every sunrise.  They're chomping down all our food supply.  You have gotta get your can in the drink and kill them.  Take one of their teeth to old Wickystick and see what she has to say about Fiddy then!  I will also give you some booty for any teeth you pull out of this river.  Well, get going. Deputy $name!");
	}
}

sub EVENT_ITEM {
	#:: Match a 13870 - Piranha Tooth
	if (plugin::check_handin(\%itemcount, 13870 => 1)) {
		quest::say("Whew!! We are sure on the way to saving this village, pal! They're gonna erect a statue in our names.  Fishslayers is what we are!  Let's keep up the good work!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(292, 1); 		#:: + Merchants of Rivervale
		quest::faction(241, 1);			#:: + Deeppockets
		quest::faction(263, 1);			#:: + Guardians of the Vale
		quest::faction(286, 1); 		#:: + Mayor Gubbin
		quest::faction(336, -1);		#:: - Coalition of Tradefolk Underground
		#:: Grant a small amount of experience
		quest::exp(15);
		#:: Create a hash for storing cash - 170 to 200cp
		my %cash = plugin::RandomCash(170,200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
