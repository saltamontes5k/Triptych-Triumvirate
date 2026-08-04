sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to the lands of Ro. Stand and fight with me. We shall fight to reclaim the desert in the name of Solusek Ro. Death to all [dervish cutthroats]!!");
	}
	elsif ($text=~/dervish cutthroats/i) {
		quest::say("The dervish cutthroats are the vile scum who inhabit the desert. They are rogues who assault wayward travelers. Solusek Ro has commanded their extermination!! Do you wish to [join the crusade]?");
	}
	elsif ($text=~/join the crusade/i) {
		quest::emote("grins enthusiastically. 'The scum rarely wander far from their camps. Hunt them down and I will reward you for every three insignia rings you bring as proof of their deaths.'");
	}
}

sub EVENT_ITEM {
	#:: Match three 1903 - Cutthroat Insignia Ring
	if (plugin::check_handin(\%itemcount, 1903 => 3)) {
		quest::say("You will make a fine addition to the crusade. Continue the cleansing of the desert. Let it be known that the Defenders of Ro are here to challenge the evils of the desert. I call upon the righteousness of all paladins to assist me.");
		#:: Give a random reward:  7012 - Bronze Dagger, 5026 - Bronze Short Sword, 5015 - Rusty Scythe, or 6017 - Splintering Club
		quest::summonitem(quest::ChooseRandom(7012, 5026, 5015, 6017));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(5029, 5);		#:: + Temple Of Sol Ro
		quest::faction(416, -1);		#:: - Shadowed Men
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 40 to 60cp
		my %cash = plugin::RandomCash(40,60);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 12348 - Gem of Stamina and a 12349 - Sparkling Sapphire
	elsif (plugin::check_handin(\%itemcount, 12348 => 1, 12349 => 1)) {
		quest::say("You serve the Burning Prince as I do. The Redeemed has instructed me to give you this reward upon completion of your test. Practice your arts and prepare yourself. Evil approaches our realm. Long live Ro!!");
		#:: Give a 7041 - Burning Rapier
		quest::summonitem(17041);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(5029,10);		#:: + Temple Of Sol Ro
		quest::faction(416,-10);		#:: - Shadowed Men
		#:: Grant a moderate amount of experience
		quest::exp(1000);
		#:: Create a hash for storing cash - 3750 to 4250cp
		my %cash = plugin::RandomCash(3750,4250);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
