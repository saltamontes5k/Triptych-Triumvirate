sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings. I am Ulan Meadowgreen of the family Meadowgreen. My brother and I are the best Armorers in all of Norrath. We craft [armor] for the bravest warriors in the land. If you are a Warrior of renown, and are interested in our armor, I have some mighty [labors] which you might attempt for me.");
	}
	elsif ($text=~/armor/i) {
		quest::say("I smith [Bracers], [Greaves], [Pauldrons] and [Breastplates]. My brother Shakrn smiths Helms, Gauntlets, Boots and Vambraces.");
	}
	elsif ($text=~/labors/i) {
		quest::say("Only those that can prove themselves mighty warriors deserve to wear our Crafted Armor. While my brother prefers trophies, I seek instead tasks which will help my craft and my people.");
	}
	elsif ($text=~/bracers/i) {
		quest::say("The fine sheen you see on our crafted armor is produced by a mixture of river berries and juice squeezed from the optic nerves of an evil eye. We are always in need of more optic nerves for our armor. Bring me a handful of optic nerves and a [sapphire], and I will give you a crafted bracer for your trouble.");
	}
	elsif ($text=~/sapphire/i) {
		quest::say("I need a sapphire for a piece of jewelry my brother and I are working on.");
	}
	elsif ($text=~/greaves/i) {
		quest::say("Years ago, a Necromancer most foul terrorized the people of the Karana's. This wretch stole a [circlet] that father was smithing for my sister. It was very easy to recognize - shining silver like the light of dawn breaking. I have heard rumors that this Necromancer has settled in the depths of Najena. Return this circlet to me and gift me with two [Star Rubies], and I will reward you with Crafted Greaves.");
	}
	elsif ($text=~/circlet/i) {
		quest::say("The circlet that my father forged was of the finest silver, ready to be enchanted by our more magical cousins. It is a shame that we never had the chance to finish the work.");
	}
	elsif ($text=~/star rubies/i) {
		quest::say("I need a Star Ruby for a piece of jewelry that my brother and I are working on.")
	}
	elsif ($text=~/pauldron/i) {
		quest::say("'In the Caverns of Clan Runny Eye live several Evil Eyes of prestigious magical power. Split amongst them are the three lost pieces of the legendary [Rune of Dwarves]. When assembled, this Rune is said to impart a mystic skill to the smith who holds it. Bring me these three pieces and a [Fire Emerald], and I will smith for you a Pauldron worthy of the mightiest of warriors.");
	}
	elsif ($text=~/rune of dwarves/i) {
		quest::say("The Rune of Dwarves once rested in the Heart of the Ctiy of Kaladim. Years ago the Goblins of Clan Runny Eye stole it from the Dwarves. No one that I have spoken to knows how it was broken. It is not hard to guess, however, why the Evil Eyes now hold them.");
	}
	elsif ($text=~/fire emerald/i) {
		quest::say("I need a fire emerald for a piece of jewelry my brother and I are creating.");
	}
	elsif ($text=~/breastplate/i) {
		quest::say("Deep within the depths of Castle Mistmoore live a particularly deadly clan of Werewolves. These are the servants of [Mayong], and he has enchanted the most ferocious of them that their talons might cut through steel. I wish to study these talons, and see if I can transfer the enchantments from them to the Crafted Armor that I make. If you bring me Werewolf talons and 3 [Rubies], then I will give to you a Breastplate the likes of which you have never before seen.");
	}
	elsif ($text=~/mayong/i) {
		quest::say("Mayong Mistmoore is the ruler of Castle Mistmoore. He has ruled there for centuries, and will most likely rule for centuries more to come. It is said that he does not age.");
	}
	elsif ($text=~/^rubies$/i) {
		quest::say("I need a Ruby for a piece of jewelry that my brother and I are working on.");
	}
}

sub EVENT_ITEM {
	#:: Match a 14019 - Bunch of Optic Nerves, and a 10034 - Sapphire
	if (plugin::check_handin(\%itemcount, 14019 => 1, 10034 => 1)) {
		quest::say("Very good. I am always in need of more optic nerves. Take this crafted bracer with my thanks.");
		#:: Give a 4177 - Crafted Bracers
		quest::summonitem(14177);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13742 - Dark Circlet, and two 10032 - Star Ruby
	elsif (plugin::check_handin(\%itemcount, 13742 => 1, 10032 => 2)) {
		quest::say("Is this.. it is! I did not recognize it at first, but this is indeed the circlet my father once crafted. It seems to have been enchanted since. Take these crafted greaves with my thanks for a job well done.");
		#:: Give a 4179 - Crafted Greaves
		quest::summonitem(14179);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13698 - Bottom of a Fractured Rune, a 13699 - Middle of a Fractured Rune, 13738 - Top of a Fractured Rune, and a 10033 - Fire Emerald
	elsif (plugin::check_handin(\%itemcount, 13698 =>1, 13699 => 1, 13738 => 1, 10033 => 1)) {
		quest::say("Most impressive - all three pieces of the dwarven rune. When joined, this shall serve me well. Take this crafted pauldron with my gratitude.");
		#:: Give a 4175 - Crafted Pauldron
		quest::summonitem(14175);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13746 - Werewolf Talon, and three 10035 - Ruby
	elsif (plugin::check_handin(\%itemcount, 13746 => 1, 10035 => 3)) {
		quest::say("'I am most impressed that you have returned from Castle Mistmoore with a Werewolf Talon. You have justly earned your Crafted Breastplate.");
		#:: Give a 4174 - Crafted Breastplate
		quest::summonitem(14174);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
