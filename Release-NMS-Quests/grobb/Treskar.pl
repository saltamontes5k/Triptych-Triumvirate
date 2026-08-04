sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("You dare speak to Master Treskar!! You be [sent by Hukulk] or you be hurtin'!! Me have no time to waste with ugly one like you!!");
	}
	elsif ($text=~/sent by hukulk/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Ha!! Hukulk accept puny troll now?!! Ha!! You join us and you join fight. Nightkeep enemy is $name enemy!! You help smash [other weak shadowknights]. Them weak. We true power!! You bash good and maybe you do [secret mission] for Treskar. Or I has sum other [work] fer you.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/other weak shadowknights/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Other shadowknights is ogre shadowknights! They name is Greenbloods. They no match for Nightkeep! We tear arms from ogre bodies. You not as powerful as Treskar so you smash young Greenbloods. You hunt YOUNG members of Greenblood shadowknights. You bring me black shadow tunic and me share treasures from Nightkeep vault with puny Burai. Go!");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/secret mission/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Nightkeep hear bashers see fungus man spore guardian at Innothule. Him protect young fungus man spores so they grow big, BIG an' attack trolls! You go find spore guardian. Smash his big red head! Bring Treskar that huge mushroom head of his to prove he walk no more. You do this and me give you froglok skin mask.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/work/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("So you not want to smash the weak Greenbloods. Dats ok, you can bring me three ruined wolf hides and a fire beetle eye. Dat help you git big enuff to smash dem.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/another/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You dun gud on the other job. I am feeling hungry, I want to make me a pie. You bring me two snake eggs and I give you a present.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/next/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("I need you to go bash dem bad orcs. The Deathfist have ruined our lands and we will not allow it. Bring me three slashed belts of the Deathfist.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
	elsif ($text=~/final/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Here is your last task. When this done, you ready to bash Greenbloods. I need two meats from wolves and 2 snake scales.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 12190 - Huge Mushroom Head
	if (plugin::check_handin(\%itemcount, 12190 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You do it! You am great knight. Me give you special froglok skin mask. Shaman make for Nightkeep. It am make you smarter like Treskar... Me tink so!");
			#:: Give a 2308 - Froglok Skin Mask
			quest::summonitem(12308);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(308, 20);		#:: + Shadowknights of Night Keep
			quest::faction(261, -3);		#:: - Green Blood Knights
			quest::faction(222, -5);		#:: - Broken Skull Clan
			quest::faction(235, 1);			#:: + Da Bashers
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 450 to 550cp
			my %cash = plugin::RandomCash(450,550);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 12190 - Huge Mushroom Head
			quest::summonitem(12190);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 12190 - Huge Mushroom Head
			quest::summonitem(12190);
		}
	}
	#:: Match three 13782 - Ruined Wolf Pelt and a 10307 - Fire Beetle Eye
	elsif (plugin::check_handin(\%itemcount, 13782 => 3, 10307 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Dats gud, here take dis armor to helps you be stronger. Come sees me when you want [another] job");
			#:: Give a 2104 - Patchwork Tunic
			quest::summonitem(12104);
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1000);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 13782 - Ruined Wolf Pelt 
			quest::summonitem(13782);
			#:: Return a 10307 - Fire Beetle Eye
			quest::summonitem(10307);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 13782 - Ruined Wolf Pelt 
			quest::summonitem(13782);
			#:: Return a 10307 - Fire Beetle Eye
			quest::summonitem(10307);
		}
	}
	#:: Match two 13088 - Snake Egg
	elsif (plugin::check_handin(\%itemcount, 13088 => 2)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Dis is good.  I go make a pie now. Here is sumting for your help. Come see me agin when you want your [next] job.");
			#:: Give a random reward: 2145 - Raw-hide Wristbands, 2140 - Raw-hide Tunic, 2144 - Raw-hide Sleeves, 2137 - Raw-hide Skullcap, 2138 - Raw-hide Mask, 2147 - Raw-hide Leggings, 2139 - Raw-hide Gorget, 2146 - Raw-hide Gloves, 2142 - Raw-hide Cloak, 2148 - Raw-hide Boots, 2143 - Raw-hide Belt
			quest::summonitem(quest::ChooseRandom(2145, 2140, 2144, 2137, 2138, 2147, 2139, 2146, 2142, 2148, 2143));
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 350 to 450cp
			my %cash = plugin::RandomCash(350,450);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 13088 - Snake Egg
			quest::summonitem(13088);
			#:: Return a 13088 - Snake Egg
			quest::summonitem(13088);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 13088 - Snake Egg
			quest::summonitem(13088);
			#:: Return a 13088 - Snake Egg
			quest::summonitem(13088);
		}
	}
	#:: Match three 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 3)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Very good! We turn you into a basher yet. Here you go. Come see me when you want your [final] task.");
			#:: Give a random reward: 6031 - Tarnished Warhammer, 5070 - Tarnished Two Handed Sword, 5071 - Tarnished Two Handed Battle Axe, 7024 - Tarnished Spear, 5042 - Tarnished Short Sword, 5047 - Tarnished Scimitar, 6033 - Tarnished Morning Star
			quest::summonitem(quest::ChooseRandom(6031, 5070, 5071, 7024, 5042, 5047, 6033));
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 450 to 550cp
			my %cash = plugin::RandomCash(450,550);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
			#:: Return a 13916 - Deathfist Slashed Belt
			quest::summonitem(13916);
		}
	}
	#:: Match two 13403 - Wolf Meat and two 13070 - Snake Scales
	elsif (plugin::check_handin(\%itemcount, 13403 => 2,13070 => 2)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Dats what I needed. Here you go.");
			#:: Give a random reward: 6014 - Rusty Warhammer, 5023 - Rusty Two Handed Sword, 6013 - Rusty Two Handed Hammer, 7009 - Rusty Spear, 5013 - Rusty Short Sword, 5021 - Rusty Scimitar
			quest::summonitem(quest::ChooseRandom(6014, 5023, 6013, 7009, 5013, 5021));
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 550 to 650cp
			my %cash = plugin::RandomCash(550,650);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 13403 - Wolf Meat
			quest::summonitem(13403);
			#:: Return a 13403 - Wolf Meat
			quest::summonitem(13403);
			#:: Return a 13070 - Snake Scales
			quest::summonitem(13070);
			#:: Return a 13070 - Snake Scales
			quest::summonitem(13070);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 13403 - Wolf Meat
			quest::summonitem(13403);
			#:: Return a 13403 - Wolf Meat
			quest::summonitem(13403);
			#:: Return a 13070 - Snake Scales
			quest::summonitem(13070);
			#:: Return a 13070 - Snake Scales
			quest::summonitem(13070);
		}
	}
	#:: Match three 12199 - Black Shadow Tunic and two gold
	elsif (plugin::check_handin(\%itemcount, 12199 => 3, "gold" => 2)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Hmm... You do good job. You surprise Treskar. Maybe you good after all. Maybe Treskar give you [secret mission]. Maybe not.");
			#:: Give a random reward: 5071 - Tarnished Two Handed Battle Axe, 5025 - Rusty Two Handed Battle Axe, 5037 - Bronze Two Handed Battle Axe
			quest::summonitem(quest::ChooseRandom(5071, 5025, 5037, 5025, 5071));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(308, 20);			#:: + Shadowknights of Night Keep
			quest::faction(261, -3);			#:: - Green Blood Knights
			quest::faction(222, -5);			#:: - Broken Skull Clan
			quest::faction(235, 1);				#:: + Da Bashers
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 100 to 200cp
			my %cash = plugin::RandomCash(100,200);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("Me talk to you 'bout dat when you do more to help Nightkeep!  Kill all Greenbloods!  Kill all froggies!");
			#:: Return a 12199 - Black Shadow Tunic
			quest::summonitem(12199);
			#:: Return a 12199 - Black Shadow Tunic
			quest::summonitem(12199);
			#:: Return Coins
			quest::givecash($copper, $silver, $gold, $platinum);
		}
		else {
			quest::say("<..Sniff, sniff, sniff..>  Me smell the blood of enemy in you.  You fool to talk to Nightkeep shadowknight!  Me bleed you if you no run!");
			#:: Return a 12199 - Black Shadow Tunic
			quest::summonitem(12199);
			#:: Return a 12199 - Black Shadow Tunic
			quest::summonitem(12199);
			#:: Return Coins
			quest::givecash($copper, $silver, $gold, $platinum);
		}
	}	
	#:: Match one 12199 - Black Shadow Tunic
	elsif (plugin::check_handin(\%itemcount, 12199 => 1)) {
		quest::say("Me change mind! Me want total of THREE ogre black shadow tunics. Ha Ha! And you also pay two gold for Nightkeep tax! Ha! Ha!");
		#:: Return a 12199 - Black Shadow Tunic
		quest::summonitem(12199);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
