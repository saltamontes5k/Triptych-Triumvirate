sub EVENT_SPAWN {
	#:: Set up a proximity, 100 unit distance
	$x = $npc->GetX();
	$y = $npc->GetY();
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	#:: Match a 18733 - Recruitment Summons
	if (plugin::check_hasitem($client, 18733)) { 
		$client->Message(15,"As your eyes adjust to the interior of your surroundings, you see Mayor Gubbin and Sheriff Roglio standing nearby. The Mayor turns towards Sheriff Roglio. 'Looks like we have another fine young recruit to join your ranks, Roglio!' Sheriff Roglio looks your way. 'Greetings, recruit. Read the note in your inventory and hand it to me when you wish to start your training.'");
	}
}  

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name! Stand tall whenever you are speaking to the Sheriff of Rivervale. I command the warriors of this vale. You must be new to the ranks of the Guardians of the Vale, so be sure to report to your squad at once. We must protect our people. The [danger] has come closer to home. If you are not a deputy, then please leave these halls.");
	}
	elsif ($text=~/danger/i) {
		quest::say("What danger?!! You must be new to the community. The goblins of Clan Runnyeye have been scaling our wall somehow. You must join our forces in exterminating every one of those beasts. Your wages are earned with every four bloody goblin warbead necklaces you return to me. Now be off and fight the good fight.");
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Tradeskills Volume I
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Tradeskills Volume II
		quest::summonitem(51122);
	}
} 

sub EVENT_ITEM {
	#:: Match a 18733 - Warrior Recruitment Letter
	if (plugin::check_handin(\%itemcount, 18733 => 1 )) {
		quest::say("Welcome to the Guardians of the Vale. I'm Roglio Bruth, and I run this proud little outfit. You seem to be of hearty stock, let's put you to work. Here's your guild tunic - hope it fits. Start your training right away. Once you are ready to begin please make sure that you see Dalario Blistbobble, he can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give item 13540 - *Old Tan Tunic
		quest::summonitem(13540);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Set factions
		quest::faction(263, 100); 	#:: + Guardians of the Vale
		quest::faction(286, 15); 	#:: + Mayor Gubbin
		quest::faction(355, 10); 	#:: + Storm Reapers
		quest::faction(292, 15); 	#:: + Merchants of Rivervale
		quest::faction(334, -15); 	#:: - Dreadguard Outer
	}
	#:: Match four 13931 - Runnyeye Warbeads
	if (plugin::check_handin(\%itemcount, 13931 => 4 )) {
		quest::say("Good work, Deputy $name! We shall soon rid our countryside of the goblin threat. Here are your wages. Eat well tonight!");
		#:: Give item 13023 - Bixie Berry Buns
		quest::summonitem(13023);
		#:: Give item 13024 - Tanglefoot Tingle Drink
		quest::summonitem(13024);
		#:: Ding!
		quest::ding();
		#:: Give a large amount of experience
		quest::exp(6400);
		#:: Create a hash for storing cash - 70 to 90cp
		my %cash = plugin::RandomCash(70,90);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(263, 1); 	#:: + Guardians of the Vale
		quest::faction(286, 1); 	#:: + Mayor Gubbin
		quest::faction(355, 1); 	#:: + Storm Reapers
		quest::faction(292, 1); 	#:: + Merchants of Rivervale
		quest::faction(334, -1); 	#:: - Dreadguard Outer
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
