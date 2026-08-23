sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to the Hall of Truth!  May the will of Mithaniel Marr guide you through life.  We are glad to see that you have an interest in our ways.  Please speak with any of my priests or knights and they shall help you find your faith.");
	}
	elsif ($text=~/militia/i) {
		quest::say("The Freeport Militia is nothing more than a ragtag band of mercenaries and convicts. They act as the guards of this troubled city. Be well aware that they are not the honorable guards you may think they are. They are commanded by Sir Lucan D'Lere, the self-proclaimed ruler of Freeport. We of the Hall of Truth shall set this city free from the grip of the Militia one day. It is our duty as Knights of Truth.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18735 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18735 => 1)) {
		quest::say("The Truthbringer welcomes you into his life. Here is the tunic of Marr. Wear it with pride and be sure to conduct yourself with valor. Once you are ready to begin your training please make sure that you see Salinsa Delfdosan, she can assist you in developing your hunting and gathering skills. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks.");
		#:: Give a 13554 - Faded Purple Tunic*
		quest::summonitem(13554);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(281, 100); 	#:: + Knights of Truth
		quest::faction(271, -15); 	#:: - Dismal Rage
		quest::faction(330, -15); 	#:: - Freeport Militia
		quest::faction(362, 20); 	#:: + Priests of Marr
		quest::faction(311, 10); 	#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 18822 - A Note
	elsif (plugin::check_handin(\%itemcount, 18822 => 1 )) {
		quest::say("You must be the young member of the Hall of Truth who was sent by Theron. I am glad to see you avoided any interference. Please take this as a reward for your service.");
		#:: Give item 9985 - Spell: Courage*
		quest::summonitem(19985);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(281, 10); 	#:: + Knights of Truth
		quest::faction(271, -1); 	#:: - Dismal Rage
		quest::faction(330, -1); 	#:: - Freeport Militia
		quest::faction(362, 2); 	#:: + Priests of Marr
		quest::faction(311, 1); 	#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 7 to 10cp
		my %cash = plugin::RandomCash(7,10);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 18816 - A Note
	elsif (plugin::check_handin(\%itemcount, 18816 => 1 )) {
		quest::say("Thank you, defender of Karana! We have heard rumors of the followers of Bertoxxulous gaining knowledge of our knight who infiltrated the ranks of the [Militia]. They would have tried to sell the information to the Militia. We will inform our knight immediately. As for you, here is a donation to your journey's expenses. Stay clear of the Freeport Militia. There is no doubt they have learned of your alliance with us.");
		#:: Give random reward: 6016 - Rusty Morning Star or 13296 - Prayer Beads
		quest::summonitem(quest::ChooseRandom(6016, 13296));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(281, 20); 	#:: + Knights of Truth
		quest::faction(271, -3); 	#:: - Dismal Rage
		quest::faction(330, -3); 	#:: - The Freeport Militia
		quest::faction(362, 4); 	#:: + Priests of Marr
		quest::faction(311, 2); 	#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 1600 to 1800cp
		my %cash = plugin::RandomCash(1600,1800);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
