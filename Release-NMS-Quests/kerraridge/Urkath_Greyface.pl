sub EVENT_SAY {
	if ($text=~/Hail/i) {
		quest::say("Errr?  What you say to Urrrkath?  Ah.  Hello to you as well. furrrless type person. Would you do Urrrkath a [favor]?");
	}
	if ($text=~/favor/i) {
		quest::say("Grrreatful I am that you would think to do this for me.  I am in need of a special leaf, called a [Sylvani Leaf], if you could brrrring this to me I would rrrrreward you verrrry well.");
	}
	if ($text=~/Sylvani Leaf/i) {
		quest::say("They say that the leaf only exists in a small forest farrrrr frrrrrom ourrrrrr island");
	}
}

sub EVENT_ITEM {
	#:: Match a 1155 - Sylvani Leaf
	if (plugin::check_handin(\%itemcount, 1155 => 1)) {
		quest::say("Excellent! I can't believe you found it.  Here is the rrrreward that I promised you.");
		#:: Give a 2045 - Worn Leather Shoulderpads
		quest::summonitem(2045);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(2000);
		#:: Set faction
		quest::faction(382,30);	# + Kerra Isle
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
