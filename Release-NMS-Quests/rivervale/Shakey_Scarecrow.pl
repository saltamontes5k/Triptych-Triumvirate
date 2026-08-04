sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("rustles and looks up at you in acknowledgment.");
		#:: Signal Reebo_Leafsway in Rivervale
		quest::signalwith(19052, 1, 0); 
	}
} 

sub EVENT_ITEM {
	#:: Turn in for 14321 - Sack of Writhing Hay
	if (plugin::check_handin(\%itemcount, 14321 => 1 )) {
		quest::emote("shakes his head around and beams a smile at you");
		#:: Give item 13980 - Wee Harvester or 14031 - Belt of the River
		quest::summonitem(quest::ChooseRandom(13980, 13980, 14031));
		#:: Ding!
		quest::ding();
		#:: Give a small amount of xp
		quest::exp(500);
		#:: Create a hash for storing cash - 4500 to 4600cp
		my %cash = plugin::RandomCash(4500,4600);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(355, 10);	#:: + Storm Reapers
		quest::faction(286, 1);		#:: + Mayor Gubbin
		quest::faction(292, 1);		#:: + Merchants of Rivervale
		quest::faction(324, -1);	#:: - Unkempt Druids
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
