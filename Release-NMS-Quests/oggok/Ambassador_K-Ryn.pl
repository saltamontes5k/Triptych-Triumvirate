sub EVENT_SAY {
	if ($text=~/hail/i ) {
		quest::say("Get your wretched hide away from me! Who knows what vile stench you have been rolling around in?! Do not speak with me unless you have some glimmer of intelligence!");
	}
}

sub EVENT_ITEM {
	#:: Match a 18842 - Sealed Letter
	if (plugin::check_handin(\%itemcount, 18842 => 1)) {
		quest::say("Another young warrior. I pray you shall not meet the fate of the last twelve. Here then. Take this report to Mistress Seloxia at once. And stay clear of the Froglok lair called Gukk.");
		#:: Give a 18843 - Sealed Letter
		quest::summonitem(18843);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(250);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH {
	quest::say("Start digging your grave. The Indigo Brotherhood shall find you.");
}
