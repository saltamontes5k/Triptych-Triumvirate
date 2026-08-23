sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, me friend! I'm the resident healer o' Halas. Please inform me when ye've a need fer me talents to [bind wounds], [cure disease] or [cure poison]. Might I add, if ye're a young shaman o' Halas, ye can also [assist in gatherin' fungus]?");
	}
	if ($text=~/bind wounds/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Before I bind yer wounds, ye must pay tribute to the Tribunal in the amount of ten gold coins.");
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
		}
	}
	elsif ($text=~/cure disease/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Two small quantities o' wooly fungus are needed before we can cure yer malady.");
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
		}
	}
	elsif ($text=~/cure poison/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("I'll be needing mammoth steaks to feed the unfortunate.  Then we'll drain the poison from yer veins.");
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
		}
	}
	elsif ($text=~/assist in gatherin' fungus/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("As the wooly spiderlings get ready to molt, they'll carry wooly fungus. Oftentimes, one can find wooly fungus growing on their bellies. I use this in me healing practices. I'll reward ye if ye can fill this jar full o' the valuable fungus. Don't forget to combine them before ye return it to me. And have yerself some rations handy, or ye may find yerself snacking on this tasteless food source.");
			#::  Give a 17946 - Empty Jar (identifies as "Jar for Wooly Fungus")
			quest::summonitem(17946);
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
		}	
	}
}

sub EVENT_ITEM {
	#:: Match ten gold
	if (plugin::takeCoin(0,0,10,0)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("The scales have been balanced and the Tribunal has spoken. Yer body shall be saved.");
			#:: Ding!
			quest::ding();
			#:: Cast 17 - Light Healing
			$npc->CastSpell(17,$userid);
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
			#:: Return unused money
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}
	#:: Match two 13967 - Wooly Fungus
	elsif (plugin::check_handin(\%itemcount, 13967 => 2)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("The scales have been balanced and the Tribunal has spoken. Yer body shall be saved.");
			#:: Ding!
			quest::ding();
			#:: Cast 213 - Cure Disease
			$npc->CastSpell(213,$userid);
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
			#:: Return two 13967 - Wooly Fungus
			quest::summonitem(13967);
			quest::summonitem(13967);
		}
	}
	#:: Match a 13445 - Mammoth Steaks
	elsif (plugin::check_handin(\%itemcount, 13445 => 1)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("The scales have been balanced and the Tribunal has spoken. Yer body shall be saved.");
			#:: Ding!
			quest::ding();
			#:: Cast 203 - Cure Poison
			$npc->CastSpell(203,$userid);
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
			#:: Return one 13445 - Mammoth Steaks
			quest::summonitem(13445);
		}
	}
	#:: Match a 13966 - Jar of Fungus
	elsif (plugin::check_handin(\%itemcount, 13966 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Aye! Ye've filled the jar. I'll see to it that Holana locks this away. Tis difficult to obtain and we can only spare the talents of our young shamans. Allow me to give ye a reward. Thank ye kindly fer yer service.");
			#:: Give a random reward: 15203 - Spell: Cure Poison, 15270 - Spell: Drowsy, 15271 - Spell: Fleeting Fury, 15275 - Spell: Frost Rift, 15036 - Spell: Gate, 15075 - Spell: Sicken
			quest::summonitem(quest::ChooseRandom(15203, 15270, 15271, 15275, 15036, 15075));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(327, 10);		#:: + Shamen of Justice
			quest::faction(328, 1);			#:: + Merchants of Halas
			quest::faction(223, -1);		#:: - Circle of Unseen Hands
			quest::faction(336, -1);		#:: - Coalition of Tradefolk Underground
			quest::faction(244, -2);		#:: - Ebon Mask
			#:: Grant a small amount of experience
			quest::exp(50);
			#:: Create a hash for storing cash - 400 to 700 cp
			my %cash = plugin::RandomCash(400,700);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			quest::say("The scales o' the Shamans o' Justice dinnae tip in yer favor. Ye'd best flee ye still have the chance.");
			#:: Return one 13966 - Jar of Fungus
			quest::summonitem(13966);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
