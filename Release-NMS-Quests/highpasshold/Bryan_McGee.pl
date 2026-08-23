sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Time to say goodbye!");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I do not know what you are doing up here, but I am a busy man. Please return to the bar downstairs and enjoy the atmosphere.");
		#:: Send a signal '1' to Highpass Hold >> Beef (5055) with no delay
		quest::signalwith(5055, 1, 0);
	}
	elsif ($text=~/never stop chopping/i) {
		quest::say("Hey!! You must be the one I traded my axe to. Funny.. I thought you were much shorter. If you have my axe I will return your gem to you. Well..? Let's have it!");
	}
	elsif ($text=~/oblong bottle/i) {
		quest::say("The oblong bottle is a legend. They say one drink and you're off to oblivion, but just before that you feel the best you've ever felt and relive all your finest memories in the blink of an eye. The last I heard, some guy by the name of Turgin Swillfod turned up in Freeport spouting that he had found it. He was never heard from again.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12366 - Never Stop Chopping
	if (plugin::check_handin(\%itemcount, 12366 => 1)) {
		quest::say("On second thought.. You can do a little favor for me first. An associate of mine has asked me to acquire a case of spirits for him. Take this box and seek out what is needed to fill it. Inside you will combine the spirits of Lendel's Grand Lager, Gator Gulp Ale, Blackburrow Swig, Tunare's Finest, Underfoot Triple Bock, Frozen Toe Rum, Blood Spirit, Vasty Deep Ale, Clockwork Oil Stout and the legendary..[Oblong Bottle].");
		#:: Give a 17984 - Bottle Crate
		quest::summonitem(17984);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(336, 10);		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 10);		#:: + Coalition of Tradefolk
		quest::faction(329, 1);			#:: + Carson McCabe
		quest::faction(230, 1);			#:: + Corrupt Qeynos Guards
		quest::faction(330, 1);			#:: + The Freeport Militia
		#:: Grant a large amount of experience
		quest::exp(15000);
		#:: Send a signal '2' to Highpass Hold >> Beef (5055) with no delay
		quest::signalwith(5055, 2, 0);
	}
	#:: Match a 12365 - Case of Spirits
	elsif (plugin::check_handin(\%itemcount, 12365 => 1)) {
		quest::say("I cannot believe you actually acquired all those drinks!! You do good work, kid. Here is the gem as I promised. And a few plat for good measure. Don't let it be said that the Axe doesn't treat his friends right.");
		#:: Give a 12348 - Gem of Stamina
		quest::summonitem(12348);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(336, 25);		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 25);		#:: + Coalition of Tradefolk
		quest::faction(329, 2);			#:: + Carson McCabe
		quest::faction(230, 1);			#:: + Corrupt Qeynos Guards
		quest::faction(330, 3);			#:: + The Freeport Militia
		#:: Grant a large amount of experience, based on level
		$client->AddLevelBasedExp(20, 17);
		#:: Create a hash for storing cash - 7100 to 8100cp
		my %cash = plugin::RandomCash(7100,8100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
