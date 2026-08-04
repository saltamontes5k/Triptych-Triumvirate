sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("It is always a pleasure to meet a new face. We have many who travel far and wide to visit our great academy. Many who brave the long trip by boat. Many who dare to cross the territory of the [Deathfist orcs].");
	}
	elsif ($text=~/deathfist orcs/i) {
		quest::say("The Deathfist are a clan of orcs. They are not very powerful, yet I hear they dabble in the circles of magic. Their skills in the ways of magic are limited. It is my duty to study them. I shall pay for your services. Will you [assist with the research]?");
	}
	elsif ($text=~/assist with the research/i) {
		quest::say("Yes. You will do. Go into the lands which surround Freeport. There you shall encounter Deathfist apprentices. They are as young as yourself and each should carry an orc cantrip. Return one for further studies. Do so and you will earn your pay as well as our respect.");
	}
	elsif ($text=~/test the might of the orc oracles/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You have heightened your knowledge to the appropriate rank. You are ready to challenge the Deathfist oracles. Do so and return one oracle scroll which any of them may have. If I am in a good mood when you return, you shall soon be summoning elementals.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The word of mouth in the Academy of Arcane Science is that you are no foe, but you have yet to prove your worth to us. Perform more tasks for the great Tara Neklene.");
		}
		else {
			quest::say("You had best leave my sight. I am a faithful member of the Academy of Arcane Science and you are no ally of ours.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13845 - Illegible Cantrip
	if (plugin::check_handin(\%itemcount, 13845 => 1)) {
		quest::say("Very fine work, my young apprentice. This shall be very useful in understanding their ways. I have heard rumors of a scribe who can decipher these scrolls. He is said to frequent the local taverns. Bah!! If I cannot decipher them, no one can!! Continue with your work. Soon you shall advance enough to [test the might of the orc oracles].");
		#:: Give a random reward: 13005 - Iron Ration, 13002 - Torch, or 13006 - Water Flask
		quest::summonitem(quest::ChooseRandom(13005, 13002, 13006));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(220, 10);	 		#:: + Arcane Scientists
		quest::faction(281, 2); 			#:: + Knights of Truth
		quest::faction(296, -1); 			#:: - Opal Darkbriar
		quest::faction(330, -1); 			#:: - The Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(25);
		#:: Create a hash for storing cash - 100 to 200cp
		my %cash = plugin::RandomCash(100,200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 13225 - Illegible Scroll
	elsif (plugin::check_handin(\%itemcount, 13225 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Wonderful! You have survived the might of an oracle. With this we can now continue our experiments. Now you may continue your teaching and study the power to summon those of earth, air, water and fire.");
			#:: Give a random reward: 15317 - Spell: Elementalkin: Air, 15058 - Spell: Elementalkin: Earth, 15316 - Spell: Elementalkin: Fire, 15315 - Spell: Elementalkin: Water, 23516 - Spell: Summon Brass Choker
			quest::summonitem(quest::ChooseRandom(15317, 15058, 15316, 15315, 23516));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(220, 15);	 		#:: + Arcane Scientists
			quest::faction(281, 3); 			#:: + Knights of Truth
			quest::faction(296, -2); 			#:: - Opal Darkbriar
			quest::faction(330, -2); 			#:: - The Freeport Militia
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 400 to 450cp
			my %cash = plugin::RandomCash(400,450);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The word of mouth in the Academy of Arcane Science is that you are no foe, but you have yet to prove your worth to us. Perform more tasks for the great Tara Neklene.");
			#:: Return a 13225 - Illegible Scroll
			quest::summonitem(13225);
		}
		else {
			quest::say("You had best leave my sight. I am a faithful member of the Academy of Arcane Science and you are no ally of ours.");
			#:: Return a 13225 - Illegible Scroll
			quest::summonitem(13225);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
