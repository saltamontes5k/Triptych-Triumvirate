sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. citizen!  I am very busy. I do not have time to speak with you.  If you have any complaints. please direct them to City Hall.  Unless. of course. you have some personal business in which I might be interested.");
	}
	if ($text=~/shrine of innoruuk/i) {
		quest::say("It is about time Pietro sent someone. You people should be lucky I allow you to conduct your business in this city. I will have you all locked up if you cannot be more prompt. Now, listen up! I want you to go out to the Commonlands. My guards have reported that a messenger from Qeynos is staying at an inn near the western edge of the Commonlands. I suspect he is carrying vital information to the Hall of Truth. I want him stopped. Bring me the message if you know what's good for you and the Dismal Rage. Now, get out of here!");
	}
}

sub EVENT_DEATH_COMPLETE {
	#spawn Sir Lucan D'Lere
	quest::spawn2(9147,0,0,$x, $y, $z, $h);
}

sub EVENT_ITEM {
	#:: Turn in for Note for the Hall of Truth 18822
	if (plugin::check_handin(\%itemcount, 18822=> 1)) {
		quest::say("So I see you decided to bring me the message. Good. I would hate to have to hunt you down. It could have gotten really messy and I hate reading bloodstained messages. Well it seems Antonius Bayle and the Knights of Truth have begun an alliance. And it sounds as though I may have a traitor among my guards. If you wish to switch your allegiance to Freeport, then find me this traitor. Bring me his militia tunic. Try to keep the blood from staining it.");
		#:: Ding!
		quest::ding();
		#:: Give xp
		quest::exp(5000);
		#:: Set factions
		quest::faction(330,10); 	#:: + Freeport Militia
		quest::faction(336,10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281,-20); 	#:: - Knights of Truth
		quest::faction(362,-20); 	#:: - Priests of Marr
	}
	#:: Turn in for Slashed Militia Tunic
	if (plugin::check_handin(\%itemcount, 13926=> 1)) {
		quest::say("So, it was Alayle! He was of no importance to us. He knew nothing. I thank you for assisting the Freeport Militia. My men shall keep an eye out for you. Unfortunately, so will the Knights of Truth. Might I suggest you spend less time in North Freeport?' ");
		#:: Ding!
		quest::ding();
		#:: Give xp
		quest::exp(7500);
		#:: Create a hash for storing cash - 120 to 500cp
		my %cash = plugin::RandomCash(120,500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(330,10); 	#:: + Freeport Militia
		quest::faction(336,10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(281,-240); 	#:: - Knights of Truth
		quest::faction(362,-40); 	#:: - Priests of Marr
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
