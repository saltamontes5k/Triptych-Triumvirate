sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, and enable proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 1);
	#:: Also enable proximity say
	quest::enable_proximity_say();
	#:: Create a timer that loops every 5 minutes
	quest::settimer("blurt", 300);
}

sub EVENT_TIMER {
	#:: Catch the "blurt" timer
	if ($timer eq "blurt") {
		#:: Stop the timer "blurt"
		quest::stoptimer("blurt");
		quest::say("Oh Dear.. I can't believe I forgot.. He must be [starving]!");
		#:: Create a timer that loops every 5 minutes
		quest::settimer("blurt", 300);
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. $name!  Welcome to Tagglefoot's Farm.  We grow nothing but the finest vegetables in our field.  We even manage to harvest the mystical jumjum stalk in our fields.  Karana has blessed us indeed, $name.");
	}
}

sub EVENT_PROXIMITY_SAY {
	if ($text=~/starving/i) {
		quest::say("Deputy Eigon! I forgot! I was supposed to bring him some turnips to eat while he is on patrol! Oh... He asked so nicely, too. I feel bad that I forgot. If only someone would take these [turnips] to the Deputy.");
	}
	if ($text=~/turnips/i) {
		quest::say("Oh, thank you so much! You can keep any payment he gives you. Be sure to tell him I'm sorry.");
		#:: Summon 16165 - Sack of Turnips
		quest::summonitem(16165);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
