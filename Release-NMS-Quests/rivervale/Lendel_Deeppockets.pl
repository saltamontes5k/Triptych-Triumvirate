sub EVENT_SPAWN {
	#:: Set a proximity 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Check for 18732 - A Tattered Note
	if (plugin::check_hasitem($client, 18732)) {
		$client->Message(15,"As you get your bearings, you see that you are inside the Fool's Gold, the best place in all of Rivervale to have a drink and relax. Before you can reflect on relaxing however, a serious looking Halfling looks your way. 'Hey you! No loitering. What's that you say! You wish to become a Rogue? Well, you are in the right place. I am Lendel. Read the note in your inventory and when you are ready to start your training, hand me your note.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Its nice to meet you $name. Allow me to introduce myself. I am Lendel Deeppockets master Assassin of Rivervale. I am personally in charge of all training we have the new recruits go through before they are sent out on specific missions.");
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Summon Item - Tradeskill Basics volume I
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Summon Item - Tradeskill Basics volume II
		quest::summonitem(51122);
	}
}

sub EVENT_SIGNAL { 
	#:: Match a signal '1' from rivervale/Gaffin_Deeppockets.pl
	if ($signal == 1) {
		quest::say("Find somebody to go see what he wants. I don't like the idea of making Hanns mad at us, but I also don't like the idea of looking over my shoulder for Stanos. He is not somebody I would care to dance with, and I DO owe him.");
	}
}


sub EVENT_ITEM {
	#:: Turn in for 18732 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18732 => 1)) {
		quest::say("HA! I asked that fool Denry to send me a professional, and this is what I get?!? Oh diddlepicks! That crotchety old coot never liked me anyway. And after all I've done for him! Hrrmf! Ah well, let's get you started and see what ya got, huh, kid? Here, wear this. Maybe I'll have Toelia break you in, huh? Yeah, that'll work! Go find her, and she'll put you to work. Just remember, we all earn our keep around here, or else it's back to hay farm for you! Oh yeah, tell her you're the new dishwasher so she knows you are on the level. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give item 13539 - Old Brown Vest*
		quest::summonitem(13539);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(241, 5);		#:: + Deeppockets
		quest::faction(223, 5);		#:: + Circle of Unseen Hands
		quest::faction(292, -5);	#:: - Merchants of Rivervale
		quest::faction(329, 5);		#:: + Carson McCabe
		quest::faction(336, 5);		#:: + Coalition of Tradefolk Underground
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
