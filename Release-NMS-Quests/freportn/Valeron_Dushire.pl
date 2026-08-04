sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I am Sir Valeron Dushire, leader of the order of the Knights of Truth. If your soul shines with purity and strength, I urge you to join our order. The might of Mithaniel Marr stands behind all who join. Soon that might will help us free this city from the tyranny of the [Freeport Militia].");
	}
	elsif ($text=~/freeport militia/i) {
		quest::say("The Freeport Militia took control of this city long ago. They are nothing more than a group of thugs not worthy of respect. They follow the words of [Sir Lucan] D'Lere. He has been a thorn in this city's side for too long. If you wish to aid us in the fight against tyranny, go speak with Jemoz or Sir Theron. May the Truthbringer shine upon your soul.");
	}
	elsif ($text=~/sir lucan/i) {
		quest::say("Lucan is a bad seed. You see, I trained Sir Lucan. He was nothing more than a street rat who was taken in by the Temple of Marr. The priests taught him and found him to be very agile and strong. They requested either the Priests of Marr or the Knights of Truth take him on as a squire. Gygus could not spare the trainers at the time and so we took the boy. The boy became a man, and a very formidable knight. Then something [went awry].");
	}
	elsif ($text=~/went awry/i) {
		quest::say("During one of our crusades into the lands of Norrath, we left Sir Lucan in charge of the remaining knights. He did much good and the people respected him. He was overtaken by power. He soon began to hire mercenaries to guard the city, calling them the Freeport Militia. His true downfall began when he killed Sentry Dillius, a paladin of the Priests of Marr. His divine powers were stripped from his soul. He was a paladin no longer. He and his militia now control the city. They treat it as their playground and bully the populace. Someone must [stop] Sir Lucan.");
	}
	elsif ($text=~/stop/i) {
		quest::say("That would be good, but I doubt you can. We have been trying for years and are unable to get him apart from the militia. If you do the impossible and destroy Sir Lucan, bring me his testimony. Every knight of the Hall of Truth carries a signed testimony. Sir Lucan still holds his.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18737 - A tattered note
	if (plugin::check_handin(\%itemcount, 18737 => 1 )) {
		quest::say("Welcome to the Guild, here's your guild tunic. Now, let's get to work.");
		#:: Give item 13554 - Faded Purple Tunic*
		quest::summonitem(13554);
		#:: Ding!
		quest::ding();
		#:: Give a small amount of experience
		quest::exp(100);
		#:: Set factions
		quest::faction(271, -15);		#:: - Dismal Rage
		quest::faction(281, 100);		#:: + Knights of Truth
		quest::faction(330, -15);		#:: - The Freeport Militia
		quest::faction(362, 20);		#:: + Priests of Marr
		quest::faction(311, 10);		#:: + Steel Warriors
	}
	#:: Turn in for 18827 - A Testimony of Truth
	if (plugin::check_handin(\%itemcount, 18827 => 1 )) {
		quest::say("Praise be to Marr!! You have done the impossible!! Sir Lucan is finally sent to the higher courts of the Tribunal. The city now has a chance to prosper. The Hall of Truth has been redeemed and gives you thanks. Take this, it is the Sword of Faith. May you wield it with righteousness. Beware of the remainder of the militia. They will be hunting for your head.");
		#:: Give item 13947 - Brilliant Sword of Faith
		quest::summonitem(13947);
		#:: Ding!
		quest::ding();
		#:: Give a small amount of experience
		quest::exp(100);
		#:: Set factions
		quest::faction(271, -15);		#:: - Dismal Rage
		quest::faction(281, 100);		#:: + Knights of Truth
		quest::faction(330, -15);		#:: - The Freeport Militia
		quest::faction(362, 20);		#:: + Priests of Marr
		quest::faction(311, 10);		#:: + Steel Warriors
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
