sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome. Please stock up on provisions, especially if you are headed toward the lair of the vile gnolls. If so, I wish you much luck and many gnoll pelts!! I also have knowledge of a [powerful dog]. I pray you do not encounter him.");
	}
	elsif ($text=~/powerful dog/i) {
		quest::say("I have encountered a gnoll who spoke the common tongue. He dared to call himself Lord Elgnub. He swore that some day we would cross paths and he would snatch my infant son Joseph from our home. He would stand no chance against me and the mighty [Gnoll Slayer].");
	}
	elsif ($text=~/gnoll slayer/i) {
		#:: Match a 12204 - Baby Joseph Sayer
		if (plugin::check_hasitem($client, 12204)) {
			quest::say("Gnoll Slayer is the mighty longsword which was passed down unto me through generations of Sayers. My days of battle are over, but I can still wield her with ferocity. The only thing more precious would be my son, [Joseph Sayer]. I would trade Gnoll Slayer only for him to be safe and sound at home.");
		}
		else {
			quest::say("Gnoll Slayer is the mighty longsword which was passed down unto me through generations of Sayers. My days of battle are over, but I can still wield her with ferocity. The only thing more precious would be my son, Joseph Sayer. I would trade Gnoll Slayer only for him to be safe and sound at home.");
		}
	}
	elsif ($text=~/joseph sayer/i) {
		quest::say("You speak of my son, Joseph Sayer. He is but an infant and is safe here with Mira and me... At least, I believe he is.");
	}
	elsif ($text=~/true potential/i) {
		quest::say("The true potential of Gnoll Slayer is an enchantment which was once imbedded into a gnoll's eye which was placed into the hilt of the blade. The spell would help you fight off disease and call forth a wolf to fight beside you. Alas, the gnoll eye was stolen from the blade by a great, one-eyed, white gnoll. Alone with the eye, the only book which explained how to return the enchantment was also stolen. I know not where this gnoll might be. If you can find the journal and the eye, return them with the Gnoll Slayer to me for I have been searching for decades.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12204 - Baby Joseph Sayer
	if (plugin::check_handin(\%itemcount, 12204 => 1)) {
		quest::say("Baby Joseph!! Look, Momma!! Baby Joseph has been rescued by this good adventurer!! That evil Lord Elgnub made good on his word and snatched my son from under our noses. You saved the day!! For this you shall wield 'Gnoll Slayer'!! Be aware of its [true potential].");
		#:: Give a 5416 - Gnoll Slayer
		quest::summonitem(15416);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(291, 20);			#:: + Merchants of Qeynos
		quest::faction(223, -4);			#:: - Circle of Unseen Hands
		quest::faction(219, 3);				#:: + Antonius Bayle
		quest::faction(229, 2);				#:: + Coalition of Tradefolk
		quest::faction(262, 4);				#:: + Guards of Qeynos
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Match a 8357 - Gnoll's Eye, a 8356 - Journal of Greater Enchantment, and a 5416 - Gnoll Slayer
	elsif (plugin::check_handin(\%itemcount, 8357 => 1, 8356 => 1, 5416 => 1)) {
		quest::say("The eye and the journal! What a great day! The Gnoll Slayer shall be returned to full strength because of you. Your service to Qeynos will not soon be forgotten.");
		#:: Give a 5417 - Gnoll Slayer
		quest::summonitem(15417);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(291, 200);			#:: + Merchants of Qeynos
		quest::faction(223, -40);			#:: - Circle of Unseen Hands
		quest::faction(219, 30);			#:: + Antonius Bayle
		quest::faction(229, 20);			#:: + Coalition of Tradefolk
		quest::faction(262, 40);			#:: + Guards of Qeynos
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
