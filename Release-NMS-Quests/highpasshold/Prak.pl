sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Yeah, hello. I'm Prak, co-owner of the Golden Rooster. If you're thirsty, we have some great imported ales at our bar. If you're looking for a little excitement, try your hand at a little King's Court. We aim to please, my friend.");
	}
	elsif ($text=~/rid of stald/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Good.. Zannsin said you had a special talent for this sort of thing, so here's your chance to prove it. What you need to do is follow Stald on his patrol, and when the coast is clear, take him down. Good luck. Oh yeah.. not that I don't trust you or anything, but bring me back some sorta proof that Stald is dead, got it?");
		}
		else {
			#:: Create a scalar variable to store a random number
			my $RandomResponse = quest::ChooseRandom(1..4);
			#:: Match the random number
			if ($RandomResponse == 1) {
				quest::say("Is that your BREATH, or did something die in here? Now go away!");
			}
			elsif ($RandomResponse == 2) {
				quest::say("I didn't know slime could speak common. Go back to the sewer before I lose my temper!");
			}
			elsif ($RandomResponse == 3) {
				quest::say("I wonder how much I could get for the tongue of a blithering fool? Leave before I decide to find out for myself.");
			}
			else {
				quest::say("Oh look, a talking lump of refuse. How novel!");
			}
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 18795 - Letter for Prak
	if (plugin::check_handin(\%itemcount, 18795 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("I see. We think we've found out who the mole is in Carson's guards, some guy named Stald. We need to get rid of this guy as quickly, and as quietly, as possible. Carson doesn't want to cause a stink by eliminating one of his own men, so he asked us to do it. What about you? Do you think [you could get rid of Stald] for us?");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(329, 50);		#:: + Carson Mccabe
			quest::faction(336, 37);		#:: + Coalition of Tradefolk Underground
			quest::faction(304, -12);		#:: - Ring of Scale
			quest::faction(332, 50);		#:: + Highpass Guards
			quest::faction(331, 50);		#:: + Merchants of Highpass
			#:: Grant a small amount of experience
			quest::exp(500);
		}
		else {
			#:: Confirmed no text on live.
			#:: Return a 18795 - Letter for Prak
			quest::summonitem(18795);
		}
	}
	#:: Match a 13793 - Stald's Badge
	elsif (plugin::check_handin(\%itemcount, 13793 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Ah, boy! Looks like I owe Kaden two plat... I thought you'd fumble it up for sure. Well, you've impressed me friend. Here, take this back to Zan... I'll make sure to note your fine work to Carson, too, next time we speak.");
			#:: Give a 18028 - Message to Zannsin
			quest::summonitem(18028);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(329, 50);		#:: + Carson Mccabe
			quest::faction(336, 37);		#:: + Coalition of Tradefolk Underground
			quest::faction(304, -12);		#:: - Ring of Scale
			quest::faction(332, 50);		#:: + Highpass Guards
			quest::faction(331, 50);		#:: + Merchants of Highpass
			#:: Grant a small amount of experience
			quest::exp(500);
		}
		else {
			#:: Confirmed no text on live.
			#:: Return a 13793 - Stald's Badge
			quest::summonitem(13793);
		}	
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
