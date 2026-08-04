sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Who are you that you dare to speak with the great Pietro Zarn!! I see nothing more than a whelp in front of me. Innoruuk himself speaks with me. And now you expect me to waste words on you, a common. Begone $name. You have nothing to pique my interest, only my rage.");
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give a 51121 - Tradeskill Basics: Volume 1
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give a 51122 - Tradeskill Basics: Volume II
		quest::summonitem(51122);
	}
}

sub EVENT_ITEM {
	#:: Match a 18743 - A tattered Note
	if (plugin::check_handin(\%itemcount, 18743 => 1)) {
		quest::say("A new member to carry the rage of Innoruuk into the city and beyond. How wonderful. I must admit that you do not appear to carry the rage within. Hopefully you shall color the battlefields with the blood of many knights from the Hall of Truth. Here. Wear this tunic with pride. Once you are ready to begin your training please make sure that yo see Gunex Eklar, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give item 13561 - Faded Crimson Tunic
		quest::summonitem(13561);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 		#:: + Dismal Rage
		quest::faction(281, -15); 		#:: - Knights of Truth
		quest::faction(296, 20); 		#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 18961 - Translated Parchment
	elsif (plugin::check_handin(\%itemcount, 18961 => 1)) {
		quest::say("ou have proven yourself truly evil. Your hatred shall shine from this day forth. Innoruuk commands that I reward you with this. It is called Rage and it serves the powers of hate. Use it to smite the forces of good. Hail Innoruuk!");
		#:: Give item 12153 - Rage War Maul
		quest::summonitem(12153);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(271, 100); 		#:: + Dismal Rage
		quest::faction(281, -15); 		#:: - Knights of Truth
		quest::faction(296, 20); 		#:: + Opal Dark Briar
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
