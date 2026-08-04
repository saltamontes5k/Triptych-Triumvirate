sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18723 - Tattered Note
	if (plugin::check_hasitem($client, 18723)) {
		$client->Message(15,"A commanding, yet kind looking Erudite turns towards you as you attempt to get your bearings. 'Do not be startled. I am Leraena Shelyrak, Guild Master for the Clerics of Quellious. Read the note in your inventory and hand it to me when you are ready to begin your training.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome. my child.  I am Leraena Shelyrak. overseer of the Temple of Divine Light. Inside this temple. you may find the path to inner peace.  Introduce yourself to each of the priests and priestesses of the temple as well as the paladins. Together we shall put an end to such disruptive influences as the [kobold shaman].");
	}
	elsif ($text=~/kobold shaman/i) {
		#:: Match if faction is Amiable or better 
		if ($faction <= 4) {
			quest::say("The primitive kobold race has begun to show signs of healing ability.  No doubt this was granted by some evil deity.  Since they are of little power compared to a much more superior race such as ours. we only require the talents of young priests to [slay] the kobold shaman.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/slay/i) {
		#:: Match if faction is Amiable or better 
		if ($faction <= 4) {
			quest::say("You are so young...  Go to Toxxulia and find these kobold shamans.  Cut off their paws and return them to me.  I require three paws as proof of your worth to our temple.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/guild coin/i) {
		quest::say("Yes, of course. Here it is. Remember that it is not a form of currency.");
		#:: Give item 13989 - Peacekeeper Token
		quest::summonitem(13989);
	}
	#if ($text=~/powerful kobold shaman/i) { Quellious Disciple Quest - Stonebrunt Expansion
		#quest::say("There are obviously other shaman with greater healing ability than those we have yet seen.  Take this pouch and collect some of their odd necklaces so that we may study them.");
		#:: Give item 17090 - Small Embroidered Sack
		#quest::summonitem(17090);
	#}
	#if ($text=~/greater kobold shaman/i) { Quellious Initiate Quest - Stonebrunt/Warrens Expansion
		#quest::say("Return to the Warrens and obtain eight of the bronze symbols worn by the kobolds greater shaman. Place them in this sack that has been blessed by the powers of Quellious to protect you from the evil influence of the evil symbols. Return the full sack with your initiate symbol of Quellious.");
		#:: Give item 17090 - Small Embroidered Sack
		#quest::summonitem(17090);
	#}
	#if ($text=~/ready to advance/i) { Quellious Regent Quest - Stonebrunt/Warrens Expansion
		#quest::say("You are ready to strike at the body of the kobold shamans power. There is no reasoning with the Kobolds thus there shall be no peace in our beloved lands until their devotion to their wicked deity ceases. Return once again to the Warrens and bring me the unholy symbol worn by the High Shaman.");
	#}
}

sub EVENT_ITEM {
	#:: Match a 18723 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18723 => 1)) {
		quest::say("Greetings. and welcome to the Temple of Divine Light! Here is your guild tunic. Serve Quellious well. Please see Lumi Stergnon - he has a task for you.");
		#:: Give item 135546 - Faded Silver Tunic
		quest::summonitem(13546);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(298, 100); 	#:: + Peace Keepers
		quest::faction(266, 25); 	#:: + High Council of Erudin
		quest::faction(265, -25); 	#:: - Heretics
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Turn in for 2049 -  Rolled Up Strip of Cloth for Catman Alliance Quest (Warrens Expansion)
	#if (plugin::check_handin(\%itemcount, 2049 => 1)) {
		#quest::say("This is important news indeed. It seems there is a tribe of cat men in the Stonebrunt Mountains that wishes to form an alliance with Erudin. I must alert the High Council of this immediately, thank you for your services.");
		#:: Give a small amount of xp
		#quest::exp(1000);
		#:: Ding!
		#quest::ding();
		#:: Set faction
		#quest::faction(298,5); 	#:: + Peace Keepers
		#quest::faction(266,5); 	#:: + High Council of Erudin
		#quest::faction(265,-5); 	#:: - Heretics
		#quest::givecash(8,2,0,0);	#:: Give a small amount of cash copper - plat
	#}
	#:: Match three 13883 - Odd Kobold Paw
	elsif (plugin::check_handin(\%itemcount, 13883 => 3)) {
		#:: Match if faction is Amiable or better 
		if ($faction <= 4) {
			quest::say("Fine work. They shall never lay hands upon another kobold again. I mean paws. Here is a small reward for a fine job. Unfortunatly we have recently learned that the shamen in the forest are merely underlings to more [powerful kobold shaman] that reside in the kobold warrens. Continue the work of Quellious.");
			#:: Give a random reward: 15011 - Spell: Holy Armor, 15213 - Spell: Cure Disease, 15216 - Spell: Stun, 15212 - Spell: Cure Blindness
			quest::summonitem(quest::ChooseRandom(15011, 15213, 15216, 15212));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 20); 	#:: + Peace Keepers
			quest::faction(266, 5); 	#:: + High Council of Erudin
			quest::faction(265, -5); 	#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(500);
			#:: Create a hash for storing cash - 150 to 200cp
			my %cash = plugin::RandomCash(150,200);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return three 13883 - Odd Kobold Paw
			quest::summonitem(13883);
			quest::summonitem(13883);
			quest::summonitem(13883);
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	#:: Match two 13883 - Odd Kobold Paw
	elsif (plugin::check_handin(\%itemcount, 13883 => 2)) {
		#:: Match if faction is Amiable or better 
		if ($faction <= 4) {
			quest::say("I instructed you to return THREE paws.");
			#:: Return two 13883 - Odd Kobold Paw
			quest::summonitem(13883);
			quest::summonitem(13883);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return two 13883 - Odd Kobold Paw
			quest::summonitem(13883);
			quest::summonitem(13883);
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	#:: Match one 13883 - Odd Kobold Paw
	elsif (plugin::check_handin(\%itemcount, 13883 => 1)) {
		#:: Match if faction is Amiable or better 
		if ($faction <= 4) {
			quest::say("I instructed you to return THREE paws.");
			#:: Return one 13883 - Odd Kobold Paw
			quest::summonitem(13883);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return one 13883 - Odd Kobold Paw
			quest::summonitem(13883);
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	#:: Turn in for 14582 -  Embroidered Bag of Bone Necklaces Quellious Disciple Quest - Stonebrunt/Warrens Expansion
	#if (plugin::check_handin(\%itemcount, 14582 => 1)) {
		#quest::say("I am unfamiliar with the markings that adorn these necklaces. You have done well thus far in hindering the kobolds worship of their evil deity. I award you the Initiate Symbol of Quellious. Return to me when you feel you are ready to deal with the [greater kobold shaman].");
		#:: Give item 1564 - Initiate Symbol of Quellious
		#quest::summonitem(11564);
	#}
	#:: Turn in for 1458 -  Embroidered bag of Bronze Symbols and 1564 Initiate Symbol of Quellious - Quellious Initiate Quest - Stonebrunt/Warrens Expansion
	#if (plugin::check_handin(\%itemcount, 14583 => 1, 1565 =>1)) {
		#quest::say("Your service to this temple is commendable. I award you the rank of Disciple for your devotions to The Tranquil. When you are [ready to advance] return to me and I will set you upon another task.");
		#:: Give item 1565 - Disciple Symbol of Quellious
		#quest::summonitem(11565);
		#:: Give a small amount of xp
		#quest::exp(500);
		#:: Ding!
		#quest::ding();
		#:: Set faction
		#quest::faction(298,20); 	#:: + Peace Keepers
		#quest::faction(266,20); 	#:: + High Council of Erudin
		#quest::faction(265,-20); 	#:: - Heretics
	#}
	#:: Turn in for 14585 -  Odd Cold Iron Necklace  Quellious Regent Quest - Stonebrunt/Warrens Expansion
	#if (plugin::check_handin(\%itemcount, 14585 => 1)) {
		#quest::say("It is imperative that we discern the nature of these symbols and the source of the kobolds shamanistic powers. There is a citizen of Erudin residing in Freeport named Glyssa Sonshaw. She is quite possibly the most knowledgeable individual in the field of heraldic and hieroglyphic studies. Take the high shamans necklace and this note to her. When you have discovered the nature of the symbols return to me with the documentation and your Disciple Symbol of Quellious.");
		#:: Give item 1772- Sealed Parchment and 14585 Odd Cold Iron Necklace
		#quest::summonitem(11772);
		#quest::summonitem(14585);
	#}
	#:: Turn in for 1780 -  Hieroglyph Translations, 1781 Encrypted document, and 1565 Disciple Symbol of Quellious  Quellious Regent Quest - Stonebrunt/Warrens Expansion
	#if (plugin::check_handin(\%itemcount, 1780 => 1, 1781 => 1, 1565 =>1)) {
		#quest::say("You have done well yet again, young disciple. I award you the rank of Regent of the Peacekeepers. With this information we can hopefully gain some insight into the workings of the kobolds' religion.");
		#:: Give item 1566 - Regent Symbol of Quellious
		#quest::summonitem(11566);
		#:: Give a small amount of xp
		#quest::exp(1000);
		#:: Ding!
		#quest::ding();
		#:: Set faction
		#quest::faction(298,20); 	#:: + Peace Keepers
		#quest::faction(266,20); 	#:: + High Council of Erudin
		#quest::faction(265,-20); 	#:: - Heretics
	#}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
