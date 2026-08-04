sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Huh!? Leave now before my pets devour you!");
	}
	elsif ($text=~/sheets of music/i) {
		quest::say("So you seek the two song sheets? If you truly want them, you [will help] the cause of the [Unkempt Druids]. Otherwise, you would have to [fight] me for it. So, which will it be? Will you help the Unkempt Druids or will you fight me?");
	}
	elsif ($text=~/unkempt druids/i) {
		quest::say("The Unkempt Druids are the voices of the trees and the animals. We fight for the hunted prey and the vanishing forests. We are the true druids and rangers who fight for the preservation of nature. If humanoid lives must be sacrificed to meet this goal, then so be it!");
	}
	elsif ($text=~/will help/i) {
		quest::say("Wise decision. I ask you then, to go to the western plains of Karana. Seek a farmer called Linaya Sowlin. Bring me her heart. A heart for a song sheet. Fitting, don't you think?");
	}
	elsif ($text=~/join|become/i) {
		quest::say("Then you will wait here for Master Jale Phlintoes. He will be arriving here soon.");
		#:: Spawn one and only one The Southern Plains of Karana >> Jale_Phlintoes (14172) on path grid 109
		quest::unique_spawn(14172, 109, 0, -3723, -5561, 0,0);
	}	
	elsif ($text=~/flute/i) {
		quest::say("'A flute, eh? I do have a flute I got from a bard named Cordelia. You can have it if you do me a [favor].");
	}
	elsif ($text=~/favor/i) {
		quest::say("Oh! Will you? Well then, go into the Plains of Karana and search for a man named Talym Shoontar. He is a murderer of Norrath's creatures. He must be stopped! Bring me his head and you shall have your flute.");
	}
	elsif ($text=~/kill|fight/i) {
		#:: Attack the player who triggered the event
		quest::attack($name);
	}
}

sub EVENT_ITEM {
	#:: Match a 13854 - Human Heart
	if (plugin::check_handin(\%itemcount, 13854 => 1)) {
		quest::say("Good work, my friend! I thank you and the Unkempt Druids thank you. Unfortunately I have sold the other song sheet to a traveling bard of the plains. I believe her name was Cordelia. Now be on your way. Unless you plan to [join the Unkempt Druids]..?");
		#:: Give a 13116 - Winds of Karana sheet 1
		quest::summonitem(13116);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(324, 20);		#:: + Unkempt Druids
		quest::faction(262, -5);		#:: - Guards of Qeynos
		quest::faction(272, -15);		#:: - Jaggedpine Treefolk
		quest::faction(343, 10);		#:: + QRG Protected Animals
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Match a 13913 - Barbarian Head
	elsif (plugin::check_handin(\%itemcount, 13913 => 1)) {
		quest::say("What fine work you do! In the name of all Norrath's beasts and of the Unkempt Druids, I thank you. No longer will there be senseless slaughter. Here is the flute.");
		#:: Give a 13310 - Cracked Flute
		quest::summonitem(13310);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(324, 20);		#:: + Unkempt Druids
		quest::faction(262, -5);		#:: - Guards of Qeynos
		quest::faction(272, -15);		#:: - Jaggedpine Treefolk
		quest::faction(343, 10);		#:: + QRG Protected Animals
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
