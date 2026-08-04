sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Greetings, $name. Welcome to the fishing village of Clan McMannus. We sell what we can here. Have a look around but, please do not buy too much. We must save most of our stock for delivery to our home");
		}
		else {
			quest::say("Welcome to the village of McMannus. We sell many goods. Feel free to look around - just keep your hands to yourself. Good day.");
		}
	}
	elsif ($text=~/fugitive/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Searching for someone, eh? You will most likely never find them on the plains. This is a vast area. I could have Frostbite help you search. He is quite good at [tracking prey].");
		}
		else {
			quest::say("I see they have sent someone to hunt the scoundrel down. I am afraid I haven't seen the barbarian thief in quite some time. You can search and search for him here in the western plains, but I doubt you shall find him. Good luck.");
		}
	}
	elsif ($text=~/tracking prey/i) {
	   	quest::say("Frostbite can track down anyone, be they man or beast. All one needs to do is obtain a SWEATY piece of clothing recently worn by the one you seek.");
     	}
	elsif ($text=~/lion meat shipment/i) {
		quest::say("That would be splinded Go to Misla and tell her you will deliver lion meat to Halas. She will instruct you.");

	}
}
	
sub EVENT_ITEM {
	#:: Match a 18831 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18831 => 1)) {
		quest::say("Yes. We almost forgot of the shipment of Karana clovers. Here you are, my friend. Back to the north with you. I am sure the Shamans of Justice will need this.");
		#:: Give a 13962 - Karana Clover Shipment
		quest::summonitem(13962);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(320, 1);		#:: + Wolves of the North
		quest::faction(327, 1);		#:: + Shamen of Justice
		quest::faction(328, 1);		#:: + Merchants of Halas 
		quest::faction(311, 1);		#:: + Steel Warriors
		#:: Grant a moderate amount of experience
		quest::exp(1600);
		#:: Create a hash for storing cash - 600 to 1100 cp
		my %cash = plugin::RandomCash(600,1100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You fool! My brothers and sisters of the Wolves of the North shall hunt you down! You... are... through...");
}
