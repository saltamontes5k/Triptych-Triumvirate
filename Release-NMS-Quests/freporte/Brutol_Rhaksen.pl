sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Oh, hello down there, puny one. I'm Brutol Rhaksen, Commmander of warriors who serve the Dismal Rage, and that's really all you need to know..for now.");
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
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
	#:: Match a 18857 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18857 => 1)) {
		quest::say("Hahaha... I sure hope you prove more valuable than you look, little one. Once you are ready to begin your training please let me know and I will get you started. I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give a 13561 - Faded Crimson Tunic
		quest::summonitem(13561);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(271, 100); 	#:: + Dismal Rage
		quest::faction(281, -15); 	#:: - Knights of Truth
		quest::faction(296, 20); 	#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
