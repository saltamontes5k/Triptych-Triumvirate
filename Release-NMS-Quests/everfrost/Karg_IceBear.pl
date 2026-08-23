sub EVENT_SPAWN {
	#:: Create a timer 'depop' that loops every 1800 seconds (30 min)
	quest::settimer("depop", 1800);
}

sub EVENT_TIMER {
	#:: Match timer 'depop'
	if ($timer eq "depop") {
		# Stop timer 'depop' from looping
		quest::stoptimer("depop");
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, traveller! I am Karg of Clan Icebear, lone hunter of the Everfrost Peaks. Have you seen any polar bears about?");
	}
	elsif ($text=~/yes/i) {
		quest::say("I hunt polar bears and furnish cloaks from their [pelts]. They keep you warm in this cold weather.");
	}
	elsif ($text=~/pelts/i) {
		quest::say("Have you some polar bear pelts? You know I can furnish warm cloaks from them, and for you I will do it for the measly sum of 5 platinum pieces.");
	}
	elsif ($text=~/werewolf/i) {
		quest::say("Werewolf?! I have not seen a werewolf in years. Have you slain one and collected its [skin] or [claws]?");
	}
	elsif ($text=~/skin/i) {
		quest::say("You have managed to procure a werewolf skin?? Amazing! Well then, I will let you know that for a fee of 100 platinum, I can craft a hearty cloak for you if you leave the skin and the coin with me.");
	}
	elsif ($text=~/claws/i) {
		quest::say("Oh, a werewolf claw? If you were to give me the claw and 75 platinum, I could craft excellent gauntlets.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13761 - Polar Bear Skin and 5pp
	if (plugin::check_handin(\%itemcount, 13761 => 1, "platinum" => 5)) {
		quest::say("Here is your polar bear cloak! It will serve you well and keep you warm even in the coldest conditions. Farewell, friend.");
		#:: Give a 2912 - Polar Bear Cloak
		quest::summonitem(12912);
		#:: Ding!
		quest::ding();
	}
	#:: Match a 13715 - Werewolf Claws and 75pp
	elsif (plugin::check_handin(\%itemcount, 13715 => 1, "platinum" => 75)) {
		quest::say("It has been a long time since I crafted items from werewolves. I hope this aids you in your journeys. Farewell, friend, until we meet again");
		#:: Give a 2402 - Lupine Claw Gauntlets
		quest::summonitem(12402); # Lupine Claw Gauntlets
		#:: Ding!
		quest::ding();
	}
	#:: Match a 13714 - Werewolf Pelt and 100pp
	elsif (plugin::check_handin(\%itemcount, 13714 => 1, "platinum" => 100)) {
		quest::say("It has been a long time since I crafted items from werewolves. I hope this aids you in your journeys. Farewell, friend, until we meet again");
		#:: Give a 2401 - Werewolf Skin Cloak
		quest::summonitem(12401);
		#:: Ding!
		quest::ding();
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}