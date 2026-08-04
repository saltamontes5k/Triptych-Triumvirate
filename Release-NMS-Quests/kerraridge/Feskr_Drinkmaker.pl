sub EVENT_SAY {
	if ($text=~/Hail/i) {
		quest::say("Erh?  If you not be here to help Feskr with his [problem] then Feskr want you to leave.");
	}
	if ($text=~/problem/i) {
		quest::say("You wish to help?  Orrderrr of supplies I rrequest not arrive; ship sink.  Now Feskr needs supplies.  Feskr need bottle of Tunare's Finest, thunderhoof mushroom, tea leaf, and handmade backpack.  Rrrr. Strange items but Feskr need to sell.  You bring. Feskr give you nice bag.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12360 - Tunare's Finest, 14914 - Thunderhoof Mushroom, 14915 - Tea Leaves, 17969 - Hand Made Backpack
	if (plugin::check_handin(\%itemcount, 12360 => 1, 14914 => 1, 14915 => 1, 17969 => 1)) {
		quest::say("Ahhh. This will help. Many Kerrans will like these. Here. Take this old bag. I have too many. Maybe it help you.");
		#:: Give a 17032 - Rough Leather Sack
		quest::summonitem(17032);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(382,5);	# + Kerra Isle
		#:: Grant a moderate amount of experience
		quest::exp(5000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
