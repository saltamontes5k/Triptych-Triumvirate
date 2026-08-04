sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Away from carver Cagrek you get!! Me's a busy troll. Must punish enmees of Grobb and feeds trolls a plenty. Trolls complain meats no good.  Dey says dey hears ogres have special meat which taste better den pris'ners of Grobb. Do you knows name of meat? What kinda [hehe meat] dat be? Tell me!!");
	}
	elsif ($text=~/hehe meat/i) {
		quest::say("HEHE meat!! What dat stand for? Mes need some of dis HEHE meat!! Gos and get me some. Cagrek not just want some. Cagrek want more dan twenny!! Cagrek want three HEHE meat and mes want HEHE recipe. You get and me makes $name honeraree carver. Me gives you Grobb Cleaver. It cuts skins like dey butter!!");
	}
	elsif ($text=~/fungus dung pie/i) {
		quest::say("Oh nos!!! Him wants anudder wum?!! Me just makes wum fer him!! You gos ta swamp and gets me sume spore mushrooms. Be carefuls, dey easy ta bash, but sumtimes yous bash dem too gud and dey fall apparts. Gets me four and me can make pie.");
	}
	elsif ($text=~/oven mittens/i) {
		quest::say("Oven Mittens?!! Whut you need for? You no cook!! If you be tinkin you a cook me will gives you Oven Mittens, but first you brings me tree, not Wun or Too, but Tree Groglok Meats and also gives me Ten gold. You do dis den you get Grobb Oven Mittens.");
	}
}

sub EVENT_ITEM {
	#:: Match three 13409 - Froglok Meat and 10 gold
	if (plugin::check_handin(\%itemcount, 13409 => 3, "gold" => 10)) {
		quest::say("Bouts time you gets everting!! Here is you Grobb Oven Mittens. Dey good to keep you from hot stuff.");
		#:: Give a 12211 - Grobb Oven Mittens
		quest::summonitem(12211);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(145);
		#:: Set factions
		quest::faction(235, 2);		#:: + Da Bashers
		quest::faction(222, -1);	#:: - Broken Skull Clan
	}
	#:: Match four 12191 - Spore Mushroom
	elsif (plugin::check_handin(\%itemcount, 12191 => 4)) {
		quest::say("Gud werk!! Me already, err, founds, dung part of meal. Here we go. One Fungus Dung Pie!! Enjoys.");
		#:: Give a 12210 - Fungus Dung Pie
		quest::summonitem(12210);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(145);
		#:: Create a hash for storing cash - 450 to 550cp
		my %cash = plugin::RandomCash(450,550);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(235, 5);		#:: + Da Bashers
		quest::faction(222, -1);	#:: - Broken Skull Clan
	}
	#:: Match three 13368 - HEHE Meat and a 18940 - Tattered Recipe
	elsif (plugin::check_handin(\%itemcount, 13368 => 3, 18940 => 1)) {
		quest::say("Finally!! What takes yous so long? Now carver Cagrek try and makes meat and feeds to trolls. Yous getting to be deputy carver. Mes give you Grobb cleaver!! Make strong and smarts on you it will. Just like carver Cagrek.");
		#:: Give a 5413 - Grobb Cleaver
		quest::summonitem(15413);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(1500);
		#:: Create a hash for storing cash - 2900 to 3100cp
		my %cash = plugin::RandomCash(2900,3100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(235, 30);		#:: + Da Bashers
		quest::faction(222, -4);	#:: - Broken Skull Clan
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
