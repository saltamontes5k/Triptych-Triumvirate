#:: Create a scalar variable to store an item count
my $ItemCount;

sub EVENT_SPAWN {
	#:: Reset item count on spawn
	$ItemCount = 0;
}

sub EVENT_AGGRO {
	quest::say("Prepare to meet your maker!!");
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: When NPC arrives at waypoint 12
	if ($wp == 12) {
		quest::say("I will be back soon, Pandos.  Please keep an eye on my room for me.");
		#:: Send a signal "3" to West Freeport >> Pandos_Flintside (9057) after 3 seconds
		quest::signalwith(9057,3,3000);
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. It is always good to meet someone new. I am Lady Shae of the House of Dumas. And what [house] are you from?");
	}
	elsif ($text=~/house|no house/i) {
		quest::say("Good. I care not to hang around any snobs this evening. Would you be so kind as to buy me some wine?");
	}
	elsif ($text=~/steel warriors sent me/i) {
		quest::say("Thank you for checking into this matter. I told the Militia, but they just ignored me. It appears the dark elves keep coming in leaving mail for [Shintl] Lowbrew. Before I tell you more could you please buy me a white wine please?");
	}
	elsif ($text=~/shintl/i) {
		quest::say("Oh, please!!  Do not mention that horrid little person!  My stay here has turned into a nightmare because of her.  She gets mail delivered to her room every so often by dark elves, of all things.  I cannot stand the Teir'Dal!  I wonder what is in that mail.  If I just had her room key I could walk right up to the innkeeper and say, 'Mail for room two please.' That is all it would take.  But enough about her.  Let's talk about you buying me some drinks.");
	}
	#:: This is apparently an easter egg
	elsif ($text=~/^house of pancakes$/i) {
		quest::say("I can tell. You look like you ATE a house of pancakes.");
	}
	#:: This is apparently an easter egg
	elsif ($text=~/^house of style$/i) {
		quest::say("I would of never guessed by the way you look.");
	}
	elsif ($text=~/dyllin/i) {
		quest::say("Dyllin was the name of a Qeynos guard who was sent to pick up the list I was holding for dear, sweet Antonius. He left just yesterday. If you wish to meet up with him, I heard him say he was going to stop at Highpass Hold.");
	}
	elsif ($text=~/bayle list/i) {
		quest::say("Bayle List!! Oh dear!! I would have to be dancing with pink mammoths before I discussed anything to do with Antonius Bayle!!");
	}
	elsif ($text=~/pandos/i) {
		quest::say("Pandos is my body guard. He is alwayss around when I need him.");
	}
}

sub EVENT_ITEM {
	#:: Match four 13031 - White Wine
	if (plugin::check_handin(\%itemcount, 13031 => 1)) {
		quest::say("Thank you. Pandos has been telling me to try white wine forever. I mostly only drink red wine. Pardon me for getting off track. Anyway, it is a good thing you showed up. The lady in room 2 has been receiving mail from a Dark Elf. Tell Swin you [need the mail for room two]. The Innkeeper usually holds it for the guests.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(326, 1);		#:: + Emerald Warriors
		quest::faction(270, -1);	#:: - Indigo Brotherhood
		quest::faction(325, 1);		#:: + Merchants of Felwithe
		quest::faction(276, 1);		#:: + Kelethin Merchants
		#:: Grant a small amount of experience
		quest::exp(150);
	}
	#:: Match four 13030 - Red Wine
	elsif (plugin::check_handin(\%itemcount, 13030 => 4)) {
		quest::say("Oh my.. You are so kind. I can not tell you the last time I had so much fine wine. Well, there was the time Antonius Bayle told me he no longer had the time for a committed relationship. Mister big ruler of the world. Make it to the top and find someone younger. I know his plan. I hate him. I will never trust another human again. After all that, he goes and asks me to hold on to this list for him. Well I am glad it was taken from me by that [Dyllin]. Antonius Bayle has no ties to me any more!! Good riddance! Oooooh! I love him.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(326, 5);		#:: + Emerald Warriors
		quest::faction(270, -1);	#:: - Indigo Brotherhood
		quest::faction(325, 1);		#:: + Merchants of Felwithe
		quest::faction(276, 1);		#:: + Kelethin Merchants
		#:: Grant a small amount of experience
		quest::exp(150);
		#:: Reset item count
		$ItemCount = 0;
	}					
	#:: Match three 13030 - Red Wine
	elsif (plugin::check_handin(\%itemcount, 13030 => 3)) {
		if ($ItemCount == 0) {
			quest::say("Thank you... Oh my! Another of these and I will be spilling my secrets.");
			#:: Increment the item count variable
			$ItemCount++;
			$ItemCount++;
			$ItemCount++;
		}
		else {
			quest::say("Oh my.. You are so kind. I can not tell you the last time I had so much fine wine. Well, there was the time Antonius Bayle told me he no longer had the time for a committed relationship. Mister big ruler of the world. Make it to the top and find someone younger. I know his plan. I hate him. I will never trust another human again. After all that, he goes and asks me to hold on to this list for him. Well I am glad it was taken from me by that [Dyllin]. Antonius Bayle has no ties to me any more!! Good riddance! Oooooh! I love him.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(326, 5);		#:: + Emerald Warriors
			quest::faction(270, -1);	#:: - Indigo Brotherhood
			quest::faction(325, 1);		#:: + Merchants of Felwithe
			quest::faction(276, 1);		#:: + Kelethin Merchants
			#:: Grant a small amount of experience
			quest::exp(150);
			#:: Reset item count
			$ItemCount = 0;
		}
	}
	#:: Match two 13030 - Red Wine
	elsif (plugin::check_handin(\%itemcount, 13030 => 2)) {
		if ($ItemCount <= 1) {
			quest::say("Thank you... Oh my! A few more of these and I will be spilling my secrets.");
			#:: Increment the item count variable
			$ItemCount++;
			$ItemCount++;
		}
		else {
			quest::say("Oh my.. You are so kind. I can not tell you the last time I had so much fine wine. Well, there was the time Antonius Bayle told me he no longer had the time for a committed relationship. Mister big ruler of the world. Make it to the top and find someone younger. I know his plan. I hate him. I will never trust another human again. After all that, he goes and asks me to hold on to this list for him. Well I am glad it was taken from me by that [Dyllin]. Antonius Bayle has no ties to me any more!! Good riddance! Oooooh! I love him.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(326, 5);		#:: + Emerald Warriors
			quest::faction(270, -1);	#:: - Indigo Brotherhood
			quest::faction(325, 1);		#:: + Merchants of Felwithe
			quest::faction(276, 1);		#:: + Kelethin Merchants
			#:: Grant a small amount of experience
			quest::exp(150);
			#:: Reset item count variable
			$ItemCount = 0;
		}
	}
	#:: Match one 13030 - Red Wine
	elsif (plugin::check_handin(\%itemcount, 13030 => 1)) {
		if ($ItemCount <= 2) {
			quest::say("Thank you... Oh my! A few more of these and I will be spilling my secrets.");
			#:: Increment the item count variable
			$ItemCount++;
		}
		else {
			quest::say("Oh my.. You are so kind. I can not tell you the last time I had so much fine wine. Well, there was the time Antonius Bayle told me he no longer had the time for a committed relationship. Mister big ruler of the world. Make it to the top and find someone younger. I know his plan. I hate him. I will never trust another human again. After all that, he goes and asks me to hold on to this list for him. Well I am glad it was taken from me by that [Dyllin]. Antonius Bayle has no ties to me any more!! Good riddance! Oooooh! I love him.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(326, 5);		#:: + Emerald Warriors
			quest::faction(270, -1);	#:: - Indigo Brotherhood
			quest::faction(325, 1);		#:: + Merchants of Felwithe
			quest::faction(276, 1);		#:: + Kelethin Merchants
			#:: Grant a small amount of experience
			quest::exp(150);
			#:: Reset item count variable
			$ItemCount = 0;
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("The single death of a member of the Paladins of Tunare shall plague your wretched life.");
}
