sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name! I am Velan Torresk of the Ashen Order. I am in charge of training the newest members of our clan, and helping them advance their skills and rank. When members perform certain tasks on behalf of the Order, they advance to a higher rank in our clan, and are awarded a special [sash].");
	}
	elsif ($text=~/orcs/i) {
		quest::say("The Deathfist Orcs are a large tribe of Orcs who live out in the desert. They are constantly sending small raiding parties and scouts to attack Freeport and its citizens.");
	}
	elsif ($text=~/sash/i) {
		quest::say("The Sashes of Order are given out by the various trainers of our clan. I give out the [white training sash] and the [yellow Sash of Order], and Reyia is in charge of the orange and red sashes.");
	}
	elsif ($text=~/white training/i) {
		#:: Match if faction with Ashen Order is Kindly or better
		if ($faction <= 3) {
			quest::say("The white training sash of the Ashen Order is awarded to our new members for completing a few simple tasks to prove their devotion to our clan. As you know, Freeport is a very hostile place, under constant attack from [orcs], wild beasts, and even the undead. To help keep this city and its citizens relatively safe, we must help the Militia protect the main gates. Bring me two Deathfist pawn scalps from those vile [Deathfist orcs], a snake fang, and some bone chips from a skeleton. Good luck, $name, represent us well!");
		}
		else {
			quest::say("I have been watching you, and appreciate the help you've given to the brothers and sisters of the Ashen Order, but I feel that such a vital matter should be left to one of our more trusted members.");
		}
	}
	elsif ($text=~/yellow/i) {
		#:: Match if faction with Ashen Order is Kindly or better
		if ($faction <= 3) {
			quest::say("To earn the yellow sash, you must prove yourself to be very skilled in the art of fighting. The lands to the west and south of Freeport are filled with dangerous beasts that often prey upon innocent travelers. Help protect our merchant caravans and traveling citizens, while at the same time practicing your defensive skills, and eliminating these deadly creatures from the surrounding landscape. Bring me a giant snake rattle, a Deathfist slashed belt, the chitin of a desert tarantula, and turn in your white training sash, and I shall reward your noble work with our yellow Sash of Order. Good luck, $name!");
		}
		else {
			quest::say("I have been watching you, and appreciate the help you've given to the brothers and sisters of the Ashen Order, but I feel that such a vital matter should be left to one of our more trusted members.");
		}
	}
}


sub EVENT_ITEM {
	#:: Match two 13794 - Deathfist Pawn Scalp, a 13067 - Snake Fang, and a 13073 - Bone Chips
	if (plugin::check_handin(\%itemcount, 13794 => 2, 13067 => 1, 13073 => 1)) {
		#:: Match if faction with Ashen Order is Kindly or better
		if ($faction <= 3) {
			quest::say("Good work, $name, you've worked hard and proven yourself a valuable addition to the Ashen Order. Here's your white sash, wear it with pride.");
			#:: Give a 10130 - White Training Sash
			quest::summonitem(10130);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(361, 25);	 	#:: + Ashen Order
			quest::faction(281, 3); 		#:: + Knights of Truth
			quest::faction(309, 1); 		#:: + Silent Fist Clan
			#:: Grant a small amount of experience
			quest::exp(200);
		}
		else {
			quest::say("I have been watching you, and appreciate the help you've given to the brothers and sisters of the Ashen Order, but I feel that such a vital matter should be left to one of our more trusted members.");
			#:: Return two 13794 - Deathfist Pawn Scalp, a 13067 - Snake Fang, and a 13073 - Bone Chips
			quest::summonitem(13794);
			quest::summonitem(13794);
			quest::summonitem(13067);
			quest::summonitem(13073);
		}
			
	}
	#:: Match a 10130 - White Training Sash, a 13058 - Giant Snake Rattle, a 13916 - Deathfist Slashed Belt, and a 20901 - Desert Tarantula Chitin
	if (plugin::check_handin(\%itemcount, 10130 => 1, 13058 => 1, 13916 => 1,  20901 => 1)) {
		#:: Match if faction with Ashen Order is Kindly or better
		if ($faction <= 3) {
			quest::say("Ah, well done, $name. You have proven that you are a very skillful fighter and it is a honor to have you as a member of the Ashen Order. On behalf of Master Closk, and under the watchful eyes of Quellious, I present you, $name, with this, the yellow Sash of Order. Go out and make us proud.");
			#:: Give a 10131 - Yellow Sash of Order
			quest::summonitem(10131);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(361, 50);	 	#:: + Ashen Order
			quest::faction(281, 7); 		#:: + Knights of Truth
			quest::faction(309, 2); 		#:: + Silent Fist Clan
			#:: Grant a small amount of experience
			quest::exp(400);
		}
		else {
			quest::say("I have been watching you, and appreciate the help you've given to the brothers and sisters of the Ashen Order, but I feel that such a vital matter should be left to one of our more trusted members.");
			#:: Return a 10130 - White Training Sash, a 13058 - Giant Snake Rattle, a 13916 - Deathfist Slashed Belt, and a 20901 - Desert Tarantula Chitin
			quest::summonitem(10130);
			quest::summonitem(13058);
			quest::summonitem(13916);
			quest::summonitem(20901);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
