#:: Create a scalar variable to store bakery status
my $Bakery;

sub EVENT_SAY {
	if ($Bakery == 0) {
		if ($text=~/hail/i) {
			quest::say("Greetings! Please move along. I am not paid to converse with strangers... unless of course you have a muffin or two..?");
		}
		elsif ($text=~/brownloe bakery/i) {
			quest::say("Oh, yes! That is close by. I am sure Lady Shae will be fine for just a minute. I will just run there and run back. Thanks, friend!");
			#:: Start pathgrid 85 to the bakery
			quest::start(85);
			#:: Create a timer "pandos" that loops every 5 seconds
			quest::settimer("pandos",5);
			$Bakery = 1;
		}
		elsif ($text=~/lady shae/i) {
			quest::say("Lady Shae is my charge. My family is sworn to protect the House of Dumas.");
		}
	}
}

sub EVENT_TIMER {
	#:: Match timer "pandos"
	if ($timer eq "pandos") {
		if (($x == -693) && ($y == -279) && ($Bakery == 1)) {
			$Bakery = 2;
			#:: Pause for 6000 ms (6 sec)  
			quest::pause(6000); #:: WHY?
			quest::say("I sure could use some of those famous muffins you make!");
			#:: Send a signal "1" to West Freeport >> Pincia_Brownloe (9088) with a 10 second delay
			quest::signalwith(9088, 1, 10);
		}
		elsif (($x == -497) && ($y == -204) && ($Bakery == 2)) {
			#:: Stop pathgrid 85
			quest::stop();
			#:: Stop timer "pandos"
			quest::stoptimer("pandos");
			#:: Reset the scalar variable
			$Bakery = 0;
		}
	}
}

sub EVENT_SIGNAL {
	#:: Match signal "1" sent from /freportw/Pincia_Brownloe.pl
	if ($signal == 1) {
		quest::say("Thank you very much! These look delicious. Well, I need to get back to duty. I'll be back tomorrow!");
		#:: Send a signal "2" to West Freeport >> Pincia_Brownloe (9088) with a 10 second delay
		quest::signalwith(9088, 2, 10);
	}
	#:: Match a signal "2" sent from /freportw/Pincia_Brownloe.pl
	elsif ($signal == 2) {
		#:: Resume pathing on grid
		quest::resume();
	}
	#:: Match a signal "3" sent from /freportw/Lady_Shae.pl
	elsif ($signal == 3) {
		quest::say("Yes, Lady Shae.");
	}
}

sub EVENT_ITEM {
	#:: Match four 13014 - Muffin
	if (plugin::check_handin(\%itemcount, 13014 => 4)) {
		quest::say("Mmmm. This smells delicious. Oh great!! No milk!! Don't you have any sense ?! Just tell me the name of the bakery and I will run and get it myself. I am sure Lady Shae will be safe.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 4);		#:: + Faydarks Champions
		quest::faction(279, 4);		#:: + King Tearis Thex
		quest::faction(226, 4);		#:: + Clerics of Tunare
		quest::faction(310, 4);		#:: + Soldiers of Tunare
		quest::faction(234, -4);	#:: - Crushbone Orcs
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match three 13014 - Muffin
	elsif (plugin::check_handin(\%itemcount, 13014 => 3)) {
		quest::say("Mmmm. This smells delicious. Oh great!! No milk!! Don't you have any sense ?! Just tell me the name of the bakery and I will run and get it myself. I am sure Lady Shae will be safe.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 3);		#:: + Faydarks Champions
		quest::faction(279, 3);		#:: + King Tearis Thex
		quest::faction(226, 3);		#:: + Clerics of Tunare
		quest::faction(310, 3);		#:: + Soldiers of Tunare
		quest::faction(234, -3);	#:: - Crushbone Orcs
		#:: Grant a small amount of experience
		quest::exp(75);
	}
	#:: Match two 13014 - Muffin
	elsif (plugin::check_handin(\%itemcount, 13014 => 2)) {
		quest::say("Mmmm. This smells delicious. Oh great!! No milk!! Don't you have any sense ?! Just tell me the name of the bakery and I will run and get it myself. I am sure Lady Shae will be safe.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 2);		#:: + Faydarks Champions
		quest::faction(279, 2);		#:: + King Tearis Thex
		quest::faction(226, 2);		#:: + Clerics of Tunare
		quest::faction(310, 2);		#:: + Soldiers of Tunare
		quest::faction(234, -2);	#:: - Crushbone Orcs
		#:: Grant a small amount of experience
		quest::exp(50);
	}
	#:: Match a 13014 - Muffin
	elsif (plugin::check_handin(\%itemcount, 13014 => 1)) {
		quest::say("Mmmm. This smells delicious. Oh great!! No milk!! Don't you have any sense ?! Just tell me the name of the bakery and I will run and get it myself. I am sure Lady Shae will be safe.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(246, 1);		#:: + Faydarks Champions
		quest::faction(279, 1);		#:: + King Tearis Thex
		quest::faction(226, 1);		#:: + Clerics of Tunare
		quest::faction(310, 1);		#:: + Soldiers of Tunare
		quest::faction(234, -1);	#:: - Crushbone Orcs
		#:: Grant a small amount of experience
		quest::exp(25);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
