$ExpansionSetting = quest::get_rule("World:ExpansionSettings");

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Me says hi to you. What you want from me? Oh!! Me shaman trainer. You must be shaman. Are you [shaman Darkone]?");
	}
	elsif ($text=~/shaman darkone/i) {
		quest::say("You choose rite if you bes a shaman. We's da best. You remember ta not get in Kaglari way. She get mad berry easy. She gets berry mad at Bregna if she finds out me make [big mistake].");
	}
	elsif ($text=~/big mistake/i) {
		quest::say("Kaglari make me do the tasks for her. She tolds me to take crate of speshal poshuns to sumwun in Nektoolos forust. But I make mistake. I fall asleep under da trees becuz I was so tired. I wake up and poshuns are gone! Sumwun take the poshuns frum me. Dey leave dis note wit me. Me tinks dey play trick on me. Me tinks it be da stinkin' Halflings. Me needs ta gets dem back before Kaglari find out. I need sumwun to help me [find da poshuns].");
	}
	elsif ($text=~/find da poshuns/i) {
		quest::say("Take dis as it be all me know.");
		#:: Give a 18651 - Note to the Troll
		quest::summonitem(18651);
		#:: Ding!
		quest::ding();
	}
}

sub EVENT_ITEM {
	#:: Match a 13984 - Crate of Potions
	if (plugin::check_handin(\%itemcount, 13984 => 1)) {
		quest::say("Now Kaglari won't be mad at Bregna.");
		#:: Give a 12212 - Kaglari Mana Doll
		quest::summonitem(12212);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(237, 10);		#:: + Dark Ones
		quest::faction(251, -10);		#:: - Frogloks of Guk
		quest::faction(308, 10);		#:: + Shadowknights of Night Keep
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 26632 - Blood Raven Tailfeather, a 26640 - Wrulon Claw,  a 29921 - Arachnae Fangs, a 26662 - Swirling Banshee Essence
	elsif (plugin::check_handin(\%itemcount, 26632 => 1, 26640 => 1, 29921 => 1, 26662 => 1)) {
		#:: Match if Expansion Setting is Planes of Power (8) or greater
		if ($ExpansionSetting > 7) {
			quest::say("Dis am gud. I see you've been talkin' to Garuuk. Methanks you fer da help. Take dis note back ta Garuuk so he knows you helped me. Tanks again!");
			#:: Give a 28740 - Troll Receipt
			quest::summonitem(28740);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(237, 10);		#:: + Dark Ones
			quest::faction(251, -10);		#:: - Frogloks of Guk
			quest::faction(308, 10);		#:: + Shadowknights of Night Keep
			#:: Grant a large amount of experience
			quest::exp(10000);
		}
		elsif ($ExpansionSetting < 8) {
			quest::say("I have no need for these items, $name.  You can have them back.");
			#:: Return Items
			quest::summonitem(26632);
			quest::summonitem(26640);
			quest::summonitem(26621);
			quest::summonitem(26662);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
