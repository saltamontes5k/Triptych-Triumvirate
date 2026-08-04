sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. good adventurer!  I am afraid that my services are not available at the moment.  I am too worried about my [daughter].");
	}
	elsif ($text=~/daughter/i) {
		quest::say("My daughter's name is Lenara.  I have not seen her in several months. and I fear the worst.  She went off adventuring, even though I told her how dangerous it was.");
	}
	elsif ($text=~/where did she go/i) {
		quest::say("I do not know where she went, but I thought she mentioned something about lava. It still sends shivers down my spine just thinking about it.");
	}
	elsif ($text=~/where is she adventuring/i) {
		quest::say("I do not know where she went, but I thought she mentioned something about lava. It still sends shivers down my spine just thinking about it.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 5573 -  A Folded Note
	if (plugin::check_handin(\%itemcount, 5573 => 1)) {
		quest::say("Oh, my, she did get herself into some trouble! I thank you for rescuing her, my friend. Here, take this old cloak. I am afraid its power has faded, but if you bring it to my wife, she might be able to do something for you. She is currently studying in Erudin.");
		#:: Ding!
		quest::ding();
		#:: Give item 1056 - Faded Cloak
		quest::summonitem(11056);
		#:: Set faction
		quest::faction(275, 15); 		#:: + Keepers of the Art
		quest::faction(279, 3); 		#:: + King Tearis Thex
		quest::faction(246, 2); 		#:: + Faydark's Champions
		quest::faction(239, -3);	 	#:: - The Dead
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
