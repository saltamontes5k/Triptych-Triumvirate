sub EVENT_AGGRO {
	quest::say("Guards! Guards!");
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("It's time for you to take your blasphemy into the next realm.");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greet.. cough.. ings. How are you? Don't get too close to me. I have come down with something bad.");
	}
	elsif ($text=~/come down/i) {
		quest::say("Ever since I got bit by that wolf on the way to Qeynos I have been feeling ill. My strength is all gone and I.. I.. I need the [potion].");
	}
	elsif ($text=~/potion/i) {
		quest::say("I have been informed that the potions of the Temple of Life will help me. The potion is my last chance, that is what Astaed Wernor of the temple told me.");
	}
	elsif ($text=~/tiny|cleet|miller|furball|henina/i) {
		quest::say("The... <cough>... Millers own this... <cough>... farm. Cleet Miller has been good to me and lets me take breaks when I am not feeling well. The rest of the family is kind to me as well.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13954 - Prime Healer Potion
	if (plugin::check_handin(\%itemcount, 13954 => 1)) {
		quest::say("Thank you!! I felt the madness nearing my brain, but now I feel much better. Please take this as thanks - it is all I have to donate to Astaed Wemor. Be sure he gets it. I shall thank Rodcet Nife every day for sending help.");
		#:: Give a 13970 - Rusty Scythe
		quest::summonitem(13970);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(341, 1);		#:: + Priests of Life
		quest::faction(280, 1);		#:: + Knights of Thunder
		quest::faction(262, 1);		#:: + Guards of Qeynos
		quest::faction(221, -1);	#:: - Bloodsabers
		quest::faction(219, 1);		#:: + Antonius Bayle
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Match a 13955 - Prime Healer Potion
	elsif (plugin::check_handin(\%itemcount, 13955 => 1)) {
		quest::say("Please let this help.. nnnnghhh!!!.. I fear it is too late.. Aaaarrrgh!!!!.. I.. I will.. KILL YOU!!!!!");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(341, 1);		#:: + Priests of Life
		quest::faction(280, 1);		#:: + Knights of Thunder
		quest::faction(262, 1);		#:: + Guards of Qeynos
		quest::faction(221, -1);	#:: - Bloodsabers
		quest::faction(219, 1);		#:: + Antonius Bayle
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("The Priests of Life will cleanse this city of evil ones like you soon enough. May Rodcet have mercy on all our souls.");
}
