sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Check for 18729 - Tattered Note
	if (plugin::check_hasitem($client, 18729)) {
		$client->Message(15,"A commanding, yet kind looking Erudite turns towards you. 'Do not be startled. I am Lanken Rjarn, Guild Master for all aspiring Enchanters. Read the note in your inventory and hand it to me when you are ready to begin your training. I look forward to training you.'");
	}
}
	
sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("looks up irritably.");
		quest::say("I do not have time to speak with thee. I have a problem on my hands. Feel free to speak with any of my trainers.");
	}
	elsif ($text=~/problem/i) {
		quest::say("My problems are of no concern of yours. but if you must know it deals with Nolusia's brother. I can tell you no more. Leave me be.");
	}
}
	
sub EVENT_ITEM {
	#:: Match a 18729 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18729 => 1)) {
		quest::say("Welcome to the Craft Keepers! You have much to learn. and I'm sure you are anxious to get started. Here's your training robe. Go see Nolusia. she'll give you your first lesson.");
		#:: Give a 13549 - Old Patched Robe*
		quest::summonitem(13549);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 100);		#:: + Craftkeepers
		quest::faction(266, 10);		#:: + High Council of Erudin
		quest::faction(265, -15);		#:: - Heretics
		quest::faction(267, 15);		#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
