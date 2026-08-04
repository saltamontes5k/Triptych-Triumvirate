sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Excuse me! I came here in hopes of being alone!");
	}
	elsif ($text=~/sent by tani/i) {
		quest::say("You're a new rogue, then! Your mission is to kill the young daughter of the owner of the Seafarer's Roost. Wait for the right time. Why? You don't need to know. Do it and return Lyda's head to Tani in Neriak. I hope you can make it back to Neriak alive. Good hunting!");
	}
}

sub EVENT_ITEM {
	#:: Match a 18844 - Sealed Letter
	if (plugin::check_handin(\%itemcount, 18844 => 1)) {
		quest::say("I am glad to see you. We have a problem. The last runner and I attempted to carry the chest from a boat. It fell overboard! He went in after it, but the sharks made a meal of him. If you want to try and get it, it is down below in the water in the harbor. Be careful.");
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
