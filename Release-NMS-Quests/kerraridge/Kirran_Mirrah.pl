sub EVENT_ITEM {
	#:: Match a Smelly Sealed Bag
	if (plugin::check_handin(\%itemcount, 9968 => 1)) { 
		quest::say("Ahhhhhhhh! I can't believe that you ---- ahhhhhhhh! Die you, you, you evil evil heretic!");
		quest::attack($name);
	}
	plugin::return_items(\%itemcount);
}
