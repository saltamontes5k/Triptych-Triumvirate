sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What do you want? I have no reason to waste my time with the likes of you!");
	}
	elsif ($text=~/messages for neriak/i) {
		quest::say("Yes! Yes, of course. I have been waiting for you. The last four couriers made the mistake of asking the High Keep Guards for directions. Now they are breathing dirt, six feet under. Take this to Neriak at once.");
		#:: Give a 18889 - Sealed Letter
		quest::summonitem(18889 => 1);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
