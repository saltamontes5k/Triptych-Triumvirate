sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Nice to meet you. Do not the plains of Karana whistle with life. This land is truly blessed by the gods. Would you like to [hear a tune] or do you pass?");
	}
	elsif ($text=~/hear a tune/i) {
		quest::say("Inside this heart I am trapped with the sight beautiful colors, all memories of your love They attack me with full might . You left me here in this garden of grey Never to see the true colors of the happiness of day Here in my heart I sit and I cry You have left me alone and my colors have all died . What do you think? Is it a [happy] tune or a [sad] tune?");
	}
	elsif ($text=~/happy/i) {
		quest::say("It does need work. It should make the listener sad.I fear all my best tunes are behind me. That is why I am here. I am trying to write a [New Composition].");
	}
	elsif ($text=~/sad/i) {
		quest::say("It takes a broken heart to truly appreciate that tune. I am glad you enjoyed it. My dear Metala left me one year ago. The wound has healed , but the scar lives on. I am presently trying to complete a [New Composition]. Maybe that will turn me around.");
	}
	elsif ($text=~/new composition/i) {
		quest::say("I have come here to create my greatest composition. I call it 'The Winds of Karana'. Alas , but the Song Sheets have been taken from me. While I, ahem, attended to some personal business a Hermit came and stole two Song Sheets from my pack. It would be grand if in your journey you were to come upon this Hermit of the Plains and return my Song Sheets to me. I would pay kindly. I must now get back to my thoughts. Please excuse me.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13114 - Lisera Lute
	if (plugin::check_handin(\%itemcount, 13114 => 1)) {
		quest::say("Oh, dear! I forgot to repair Cassius' lute. I shall fix and return it to him myself. Thank you for bringing this to me. Here, please return this note to Cassius. He shall be most happy. Thank you again, good citizen!");
		#:: Give a 18803 - Note To Cassius
		quest::summonitem(18803);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 20);		#:: + League of Antonican Bards
		quest::faction(281, 3);			#:: + Knights of Truth
		quest::faction(262, 3);			#:: + Guards of Qeynos
		quest::faction(304, -1);		#:: - Ring of Scale
		quest::faction(285, -1);		#:: - Mayong Mistmoore
		#:: Grant a large amount of experience
		quest::exp(5000);
	}
	#:: Match a 13116 - Winds of Karana sheet 1 and a 13119 - Winds of Karana sheet 2
	elsif (plugin::check_handin(\%itemcount, 13116 =>1, 13119 => 1)) {
		quest::say("Thank you, my friend. I have just completed the composition. It is a work of art. Here. Have a copy. I hope you have the musical talent to play it. If not... Practice, practice, practice!");
		#:: Give a random reward:  15722 - Song: Jaxan's Jig o' Vigor, 15717 - Song: Selo's Accelerando, or 15703 - Song: Chords of Dissonance
		quest::summonitem(quest::ChooseRandom(15722, 15717, 15703));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(284, 30);		#:: + League of Antonican Bards
		quest::faction(281, 4);			#:: + Knights of Truth
		quest::faction(262, 4);			#:: + Guards of Qeynos
		quest::faction(304, -1);		#:: - Ring of Scale
		quest::faction(285, -1);		#:: - Mayong Mistmoore
		#:: Grant a large amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 1 to 10cp
		my %cash = plugin::RandomCash(1,10);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
