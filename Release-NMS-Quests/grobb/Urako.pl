sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Me says hi to you. What you want from me? Oh!! Me shaman trainer. You must be shaman. Are you [shaman Darkone]?");
	}
	elsif ($text=~/shaman darkone/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You choose rite if you bes a shaman. Wes da best. You remember ta not get in Kaglari way. He get mad berry easy. He gets berry mad at Urako if he finds out me make [big mistake].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Darkones no hates you, buts you not helps us enuff.");
		}
		else {
			quest::say("You die! Me Darkone!  We no frend to you.  You run now!");
		}
	}
	elsif ($text=~/big mistake/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Kaglari makes Urako cleans his kwarters. He says nots to open closet. Me make mistake and opens his closet and out comes da skeletons. Dey runs out into Grobb. Me needs ta gets dem back before Kaglari finds out. Me needs sumwun to [collect Kaglari skeletons].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Darkones no hates you, buts you not helps us enuff.");
		}
		else {
			quest::say("You die! Me Darkone!  We no frend to you.  You run now!");
		}
	}
	elsif ($text=~/collect kaglari skeletons/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Tank you!! Dere is fours of dem. You can finds dem here in Grobb. I no tink dey will want to come homes to Kaglari's closet. You ask dem to [come back to the closet] and see whut dey say. If you gets dem back me promise to gives you a [Kaglari mana doll].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Darkones no hates you, buts you not helps us enuff.");
		}
		else {
			quest::say("You die! Me Darkone!  We no frend to you.  You run now!");
		}
	}
	elsif ($text=~/kaglari mana doll/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Kaglari catch many humans. He pull spirit from dem and force into dolls. Now deir spirit give shaman extra mana. Dey good power source. Now humans good for someting. Da mana dolls only for shaman power.");
			#:: Spawn Grobb >> a_skeleton (52056)
			quest::spawn2(52056, 0, 0, -290.21, 159.80, 7.13, 0);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Darkones no hates you, buts you not helps us enuff.");
		}
		else {
			quest::say("You die! Me Darkone!  We no frend to you.  You run now!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 12213 - The Baker, a 12214 - The Butcher, a 12215 - The Captain, a 12216 - The Minstrel
	if (plugin::check_handin(\%itemcount, 12213 => 1, 12214 => 1, 12215 => 1, 12216 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Tank you. You saved me neck. Kaglari not learn me mistake now. Me give you a [Kaglari mana doll].");
			#:: Give a 12212 - Kaglari Mana Doll
			quest::summonitem(12212);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(237, 10);		#:: + Dark Ones
			quest::faction(416, 2);			#:: + Shadowknights of Night Keep
			quest::faction(251, -1);		#:: - Frogloks of Guk
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Darkones no hates you, buts you not helps us enuff.");
			#:: Return a 12213 - The Baker
			quest::summonitem(12213);
			#:: Return a 12214 - The Butcher
			quest::summonitem(12214);
			#:: Return a 12215 - The Captain
			quest::summonitem(12215);
			#:: Return a 12216 - The Minstrel
			quest::summonitem(12216);
		}
		else {
			quest::say("You die! Me Darkone!  We no frend to you.  You run now!");
			#:: Return a 12213 - The Baker
			quest::summonitem(12213);
			#:: Return a 12214 - The Butcher
			quest::summonitem(12214);
			#:: Return a 12215 - The Captain
			quest::summonitem(12215);
			#:: Return a 12216 - The Minstrel
			quest::summonitem(12216);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
