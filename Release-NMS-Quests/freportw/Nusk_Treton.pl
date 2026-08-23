sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Freeport!!  Great trade city of Norrath!!  What a wondrous place!  How do you do?  You are an [arcane scientist]. are you not?");
	}
	elsif($text=~/arcane scientist/i) {
		#:: Match if faction with Arcane Scientists is better than Indifferent
		if ($faction < 5) {
			quest::say("Grand!! I remember my younger days within this great academy. I have spent many years of research here in Freeport. I compiled a [locked journal] of my research. Alas, I am still awaiting its return.");
		}
		#:: Match if faction with Arcane Scientists is Indifferent
		elsif ($faction == 5) {
			quest::say("The word of mouth in the Academy of Arcane Science is that you are no foe, but you have yet to prove your worth to us.  Perform a tasks for the great Tara Neklene.");
		}
		#:: Match if faction with Arcane Scientists worse than Indifferent
		else {
			quest::say("You had best leave my sight.  I am a faithful member of the Academy of Arcane Science and you are no ally of ours.");
		}
	}
	elsif($text=~/locked journal/i) {
		#:: Match if faction with Arcane Scientists is better than Indifferent
		if ($faction < 5) {
			quest::say("I lent it to an old colleague of mine in Ak'Anon. He was to send it back aboard a private vessel. One Lenka Stoutheart was to return it to me. It has already been one month and counting. I wish there was a young wizard who could [seek out Lenka].");
		}
		#:: Match if faction with Arcane Scientists is Indifferent
		elsif ($faction == 5) {
			quest::say("The word of mouth in the Academy of Arcane Science is that you are no foe, but you have yet to prove your worth to us.  Perform a tasks for the great Tara Neklene.");
		}
		#:: Match if faction with Arcane Scientists worse than Indifferent
		else {
			quest::say("You had best leave my sight.  I am a faithful member of the Academy of Arcane Science and you are no ally of ours.");
		}
	}
	elsif($text=~/seek out lenka/i) {
		#:: Match if faction with Arcane Scientists is better than Indifferent
		if ($faction < 5) {
			quest::say("What luck!! I would be most appreciative if you could find Lenka Stoutheart in Freeport and inquire where the journal strongbox might be. I do so look forward to its return.");
		}
		#:: Match if faction with Arcane Scientists is Indifferent
		elsif ($faction == 5) {
			quest::say("The word of mouth in the Academy of Arcane Science is that you are no foe, but you have yet to prove your worth to us.  Perform a tasks for the great Tara Neklene.");
		}
		#:: Match if faction with Arcane Scientists worse than Indifferent
		else {
			quest::say("You had best leave my sight.  I am a faithful member of the Academy of Arcane Science and you are no ally of ours.");
		}
	}
}


sub EVENT_ITEM {
	#:: Match a 13860 - A Strongbox
	if (plugin::check_handin(\%itemcount, 13860 => 1)) {
		#:: Match if faction with Arcane Scientists is better than Indifferent	
		if ($faction < 5) {
			quest::say("Grand and fantastic!! You have made my day complete. Here is what little I can offer. Most of my money goes into my research. Thank you.");
			#:: Ding!
			quest::ding();
			#:: Set faction
			quest::faction(220, 3);	 		#:: + Arcane Scientists
			quest::faction(281, 1); 		#:: + Knights of Truth
			quest::faction(296, -5); 		#:: - Opal Darkbriar
			quest::faction(330, -5); 		#:: - The Freeport Militia
			#:: Grant a small amount of experience
			quest::exp(150);
			#:: Create a hash for storing cash - 120 to 200cp
			my %cash = plugin::RandomCash(120,200);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
