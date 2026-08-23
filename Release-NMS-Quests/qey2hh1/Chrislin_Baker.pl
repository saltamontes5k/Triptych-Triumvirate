sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("slowly lifts her head.'Have you brought any writing materials for me? The last few supplies I had were stolen.'");
	}
	elsif ($text=~/writing materials/i) {
		quest::say("A passing illusionist gave me some enchanted writing materials. He said they would help inspire me to capture my mind's images on paper. If you would just be so kind as to bring me plain old paper and a quill from Qeynos, I can get back to writing.");
	}
	elsif ($text=~/paper/i) {
		quest::say("I don't know who might be selling those these days. Just ask around. I am sure someone will know.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13063 - Piece of Parchment, and a 13051 - Quill
	if (plugin::check_handin(\%itemcount, 13063 => 1, 13051 => 1)) {
		quest::emote("gives you a hug. 'Thank you so much. I did some cleaning after you left and found this behind a barrel. It may have been left behind by the person who took my materials. You can have it.'");
		#:: Give a 12100 - Bandit Sash
		quest::summonitem(12100);
		#:: Ding!
		quest::ding();
		#:: Part of Enchanter Epic 1.0
		#:: Spawn The Western Plains of Karana >> Thrackin_Griften (12172), with no pathing grid or guild war set, at the specified location
		#:: quest::spawn2(12172, 0, 0, -11570, 878, 14, 135);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
