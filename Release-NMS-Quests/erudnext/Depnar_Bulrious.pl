sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Check for 18726 - tattered note (guild summons)
	if (plugin::check_hasitem($client, 18726)) {
		$client->Message(15,"An important looking Erudite turns to greet you as you enter the room. 'Greetings. A young recruit perhaps? I am Depnar Bulrious, your new Guild Master. Read the note in your inventory and then hand it to me when you are ready to begin your training. Truth awaits!'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. $name! I am the master of the paladins among the Peacekeepers. Have you [joined] the harmony of the Peacekeepers or are you merely a visitor?");
	}
	elsif ($text=~/joined/i) {
		quest::say("Then go and speak with the other Peacekeepers. Do your part to promote the words of Quellious.");
	}
}

sub EVENT_ITEM {
	#:: Match turn in for 18726 -  tattered note
	if (plugin::check_handin(\%itemcount, 18726 => 1)) {
		quest::say("Welcome to the Temple of Divine Light. I am Master Bulrious. Here. we study and spread the will of Quellious. Here is your guild tunic. Go find Jras Solsier. he will get you started with your first lesson.");
		#:: Give item 13546 - Faded silver Tunic*
		quest::summonitem(13546);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(298, 100);	#:: + Peace Keepers
		quest::faction(266, 25);	#:: + High Council of Erudin
		quest::faction(265, -25);	#:: - Heretics
		#:: Give a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
