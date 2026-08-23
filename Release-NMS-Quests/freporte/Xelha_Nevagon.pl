sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("A new recruit to our cause.  Just what I have been waiting for!  How would you like to serve the great Xelha Nevagon?  I need an apprentice necromancer to [assist the great Xelha].");
	}
	elsif ($text=~/assist the great xelha/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Fantastic.  Stick with me and you shall ascend in our ranks quickly.  I am in need of some components for new spells.  Will you collect them for me?  I shall need four each of the following - fire beetle eyes. bone chips and spiderling silk.  Fetch these items for me at once. Well..? Did not you hear the great Xelha? Begone!");
		}
		else {
			quest::say("Oh look..a talking lump of refuse..how novel!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match four 13099 - Spiderling Silk
	if (plugin::check_handin(\%itemcount, 13099 => 4)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Let's see here. One.. two.. three.. and.. four. Great!! Just enough for my needs. You are serving Xelha well. I give you Xelha's Sparkler. It is not much, but neither are you. You know what I really need is a cyclops eye. That would be worthy of a great reward.");
			#:: Give item 12247 - Xelha's Sparkler
			quest::summonitem(12247);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(271, 10); 		#:: + Dismal Rage
			quest::faction(281, -1); 		#:: - Knights of Truth
			quest::faction(296, 2); 		#:: + Opal Darkbriar
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 20 to 40cp
			my %cash = plugin::RandomCash(20,40);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			#:: Made up
			quest::say("You are no ally of the Dismal Rage.  Run while you still have legs!!");
			#:: Return four 13099 - Spiderling Silk
			quest::summonitem(13099);
			quest::summonitem(13099);
			quest::summonitem(13099);
			quest::summonitem(13099);
		}
	}
	#:: Match four 10307 - Fire Beetle Eye
	elsif (plugin::check_handin(\%itemcount, 10307 => 4)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("This is a good sight. I needed these to complete the current mixture. Bah!! I shall reward you for this small, very small, deed!! I pass on to you the knowledge of summoning. The more you serve, the more your faith in Innoruuk grows.");
			#:: Give a random reward: 15338 - Spell: Cavorting Bones or 15331 - Spell: Reclaim Energy
			quest::summonitem(quest::ChooseRandom(15338, 15331));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(271, 10); 		#:: + Dismal Rage
			quest::faction(281, -1); 		#:: - Knights of Truth
			quest::faction(296, 2); 		#:: + Opal Darkbriar
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 30 to 60cp
			my %cash = plugin::RandomCash(30,60);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			#:: Made up
			quest::say("You are no ally of the Dismal Rage.  Run while you still have legs!!");
			#:: Return four 10307 - Fire Beetle Eye
			quest::summonitem(10307);
			quest::summonitem(10307);
			quest::summonitem(10307);
			quest::summonitem(10307);
		}
	}
	#:: Match four 13073 - Bone Chips
	elsif (plugin::check_handin(\%itemcount, 13073 => 4)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Excellent work! You are quite the little helper. Here you go, then. A little something for your little work. Your service to me has caused Innoruuk to look upon you favorably. Your faith in our group has grown. Continue the work.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(271, 5); 		#:: + Dismal Rage
			quest::faction(281, -1); 		#:: - Knights of Truth
			quest::faction(296, 2); 		#:: + Opal Darkbriar
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 90 to 120cp
			my %cash = plugin::RandomCash(90,120);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			#:: Made up
			quest::say("You are no ally of the Dismal Rage.  Run while you still have legs!!");
			#:: Return four 13073 - Bone Chips
			quest::summonitem(13073);
			quest::summonitem(13073);
			quest::summonitem(13073);
			quest::summonitem(13073);
		}	
	}
	#:: Match a 13927 - Cyclops Eye
	elsif (plugin::check_handin(\%itemcount, 13927 => 1)) {
		#:: Match if faction is Kindly or better
		if ($faction <= 3) {
			quest::say("A cyclops eye!! You are stronger than I believed. You will rise in the ranks of the Dismal Rage quickly with acts such as this!! I am most appreciative! Here, take this. It was lying around my shelves, just gettingg all dusty. I hope you can use it. And watch yourself in your journeys, the aura of your faith in Innoruuk surrounds you like a shroud. Our enemies will surely see you for what you are.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(271, 25); 		#:: + Dismal Rage
			quest::faction(281, -3); 		#:: - Knights of Truth
			quest::faction(296, 5); 		#:: + Opal Darkbriar
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 6000 to 8000cp
			my %cash = plugin::RandomCash(6000,8000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			quest::say("I will do nothing to aid beings like you.");
			#:: Return a 13927 - Cyclops Eye
			quest::summonitem(13927);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
