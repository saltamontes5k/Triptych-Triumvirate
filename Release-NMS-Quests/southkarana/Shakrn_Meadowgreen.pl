sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. I am Shakrn Meadowgreen, Warrior extraordinaire and Master Armorer of the Meadowgreen family. My brother and I craft [armor] for the bravest warriors in the land -- do you think you [qualify]?");
	}
	elsif ($text=~/armor/i) {
		quest::say("I smith [Helms], [Gauntlets], [Boots] and [Vambraces]. My brother Ulan smiths Bracers, Greaves, Pauldruns and Breastplates.");
	}
	elsif ($text=~/qualify/i) {
		quest::say("So you are a warrior of renown?  [Prove] it to me and I will smith you [armor] befitting your exalted station.");
	}
	elsif ($text=~/prove/i) {
		quest::say("You will prove yourself to me the old fashioned way, by killing things and bringing me back proof of your deed.  Bah.  What other way is there?");
	}
	elsif ($text=~/helm/i) {
		quest::say("One of my brethren spoke to me of the mystic properties of the Fire Totems carried by the Goblin High Shaman in Solusek's Eye. My mighty Centaur body will not fit down those twisty goblin passages, so I have not been able to acquire one on my own. As proof of your powers, I ask you to bring me a Fire Totem and one [Ruby] stone. Do so and I will reward you with a Crafted Helmet.");
	}
	elsif ($text=~/ruby/i) {
		quest::say("I need a ruby for a piece of jewelry my brother and I are working on.");
	}
	elsif ($text=~/guanlets/i) {
		quest::say("Crafted Gauntlets - the mark of a distinguished warrior. I have a personal grudge to settle with those twice-cursed Aviaks. They have been raiding our merchant convoys for the last few weeks, causing mischief to no end. Bring me an Aviak charm from a Avocet - I am sure that you will not need me to tell you how to get it. An Aviak Charm and two [Star Rubies], and I will reward you with Crafted Gauntlets.");
	}
	elsif ($text=~/star rubies/i) {
		quest::say("I need a Star Ruby for a piece of jewelry that my brother and I are working on.");
	}
	elsif ($text=~/boots/i) {
		quest::say("One of my brethren spoke to me of the mystic properties of the Frost Totems carried by the Goblin High Shamans in Permafrost Keep. I have been unable to fetch one for myself, as my Centaur's body will not fit through the tunnels of those sniveling wretches. Prove your might by gifting me a Frost Totem and two [Sapphire] stones. Do this and I will reward you with a pair of Crafted Boots.");
	}
	elsif ($text=~/sapphire/i) {
		quest::say("I need a Sapphire for a piece of jewelry that my brother and I are working on.");
	}
	elsif ($text=~/vambraces/i) {
		quest::say("Come, Warrior, and speak to me of your strength. Bring me the Eye of a Griffon that I might eat it raw in the fashion of my ancestors. Do this for me - then gift me with two [Fire Emeralds], and for you I will make a Crafted Vambrace.");
	}
	elsif ($text=~/fire emerald/i) {
		quest::say("I need a Fire Emerald for a piece of jewelry that my brother and I are working on.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13743 - Goblin Fire Totem, and a 10035 - Ruby
	if (plugin::check_handin(\%itemcount, 13743 => 1,10035 => 1)) {
		quest::say("By the gods, a Fire Goblin Totem - Well done warrior! Here is your Crafted Helm. Wear it with pride, for it is a true warriors Helmet.");
		#:: Give a 4173 - Crafted Helm
		quest::summonitem(14173);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13737 - Aviak Charm, and two 10032 - Star Ruby
	elsif (plugin::check_handin(\%itemcount, 13737 => 1, 10032 => 2)) {
		quest::say("Ho ho! An aviak charm. These are not easy to come by. You have proven yourself a mighty warrior, and therefore deserve to wear these crafted warrior gauntlets.");
		#:: Give a 4178 - Crafted Gauntlets
		quest::summonitem(14178);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13744 - Goblin Frost Totem, and two 10034 - Sapphire
	elsif (plugin::check_handin(\%itemcount, 13744 => 1, 10034 => 2)) {
		quest::say("What strength you must have to return with a frost goblin totem. You have surprised me - I did not think you up to the task. Take these crafted boots - you have indeed earned them.");
		#:: Give a 4180 - Crafted Plate Boots
		quest::summonitem(14180);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Match a 13739 - Griffon Eye, and two 10033 - Fire Emerald
	elsif (plugin::check_handin(\%itemcount, 13739 => 1, 10033 => 2)) {
		quest::say("A griffon eye - I shall eat well tonight, and toast you in the manner of my ancestors. Take these crafted vambraces - they will serve you well.");
		#:: Give a 4176 - Crafted Vambraces
		quest::summonitem(14176);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(25000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
