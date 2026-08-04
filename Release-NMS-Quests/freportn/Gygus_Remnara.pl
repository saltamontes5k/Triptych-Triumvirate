sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("The Temple of Marr welcomes you. I am Gygus Remnara. High Sentinel for the Sentries of Passion. We are the order of paladins within the Priests of Marr and whose charge it is to protect the holy Temple of Marr.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18738 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18738 => 1 )) {
		quest::say("Welcome to the Sentries of Passion. We are the protectors of the Temple of Marr. Wear our tunic with pride, young knight! Find your wisdom within these walls and in the words of our priests. And remember to aid all who follow the twin deities, Mithaniel and Erollisi Marr.");
		#:: Give item 13556 - White and Blue Tunic*
		quest::summonitem(13556);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 100); 	#:: + Priests of Marr
		quest::faction(330, -10); 	#:: - The Freeport Militia
		quest::faction(281, 15); 	#:: + Knights of Truth
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
