sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings!  I am the mighty Konious Eranon, Master Enchanter, devoted follower of Innoruuk, and loyal assistant to the all-powerful Nexvok.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18856 - A tattered Note
	if (plugin::check_handin(\%itemcount, 18856 => 1)) {
		quest::say("Hey, Nex, we got another sucker.. er.. volunteer, that is, to help us out around here. Here ya go friend, put this on and let's whip you into shape.");
		#:: Give item 13566 - Blood Spotted Robe*
		quest::summonitem(13566);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 		#:: + Dismal Rage
		quest::faction(281, -15); 		#:: - Knights of Truth
		quest::faction(296, 20); 		#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
