sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Good evening. Are not the stars beautiful. Somewhere out there I imagine there is another world and another person staring right back at me. If you have business with me please save it for the morning in the palace.");
	}
	elsif ($text=~/moodoro/i) {
		quest::say("Moodoro Finharn is my brother. He was a good boy up until he met that accursed halfling named [Flynn] Merrington.");
	}
	elsif ($text=~/flynn/i) {
		quest::say("Flynn Merrington talked my brother into stealing waters from the [Vasty Deep] and selling them to any buyers they could find. The waters from the Vasty Deep are sacred. That is why they started their [business].");
	}
	elsif ($text=~/vasty deep/i) {
		quest::say("The Vasty Deep waters are said to be magical. Of course this is rumor, but it does not stop magic users from all over Norrath from trying to obtain some of the waters.");
	}
	elsif ($text=~/business/i) {
		quest::say("Flynn had talked Moodoro into delivering the waters to him in Qeynos. Eventually Moodoro was caught. He was sentenced to death, but a few spells from yours truly helped him escape death by replacing him with a [doppelganger].");
	}
	elsif ($text=~/doppelganger/i) {
		quest::say("The doppelganger's innards were pulled out its esophagus and Moodoro went to Qeynos to start a new life. Unfortunately, he found Flynn there also. Now they have started up again somehow! My guildmaster is aware of this and fears what the High Council will do to our guild when they find this out. Will you [help] me?");
	}
	elsif ($text=~/help/i) {
		quest::say("Find out how they get the water. Get me the water and I shall put a poison on the seal of the container. Then you carefully carry the container back to Flynn, not to my brother, and we shall put an end to this");
	}
}

sub EVENT_ITEM {
	#:: Match a 13118 - Erud's Tonic
	if (plugin::check_handin(\%itemcount, 13118 => 1)) {
		quest::say("Good work! Now, hold the bottle by the label! When you hand Flynn the bottle, the label will slide off. Bring me the label as proof of the deed.");
		#:: Give a 13122 - Erud's Tonic
		quest::summonitem(13122);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 20);	 		#:: + Craftkeepers
		quest::faction(266, 2); 			#:: + High Council of Erudin
		quest::faction(265, -3); 			#:: - Heretics
		quest::faction(267, 3);	 			#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Match a 13123 - Label of Erud's Tonic 
	elsif (plugin::check_handin(\%itemcount, 13123 => 1)) {
		quest::say("Fantastic. Now I can rest assured that my brother stands a better chance of finding the right path without that manipulating little man around. Master Lanken can rest assured that the waters are safe from abuse.");
		#:: Give a random reward:  13122 - Erud's Tonic, 5019 - Rusty Long Sword, 6017 - Splintering Club
		quest::summonitem(quest::ChooseRandom(13122, 5019, 6017));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(231, 30);	 		#:: + Craftkeepers
		quest::faction(266, 3);	 			#:: + High Council of Erudin
		quest::faction(265, -4); 			#:: - Heretics
		quest::faction(267, 4);	 			#:: + High Guard of Erudin
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 10 to 50cp
		my %cash = plugin::RandomCash(10,50);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
