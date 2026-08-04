sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Yes, yes, yes,  Hail to you, too, $name.  Now, quit bugging me!");
	}
	elsif ($text=~/trades/i) {
		quest::say("'I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give a 51121 - Tradeskill Basics : Volume I
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give a 51122 - Tradeskill Basics : Volume II
		quest::summonitem(51122);
	}
}

sub EVENT_ITEM {
	#:: Match a 18855 -  A Tattered note
	if (plugin::check_handin(\%itemcount, 18855 => 1)) {
		quest::say("Welcome, friend. I see more than a slight glimmer of hate in your eyes. Good, for we have much work to do. Once you are ready to begin your training please make sure that you see Marv Orilis, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give item 13565 - Old Stained Robe*
		quest::summonitem(13565);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 	#:: + Dismal Rage
		quest::faction(281, -15); 	#:: - Knights of Truth
		quest::faction(296, 20); 	#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
