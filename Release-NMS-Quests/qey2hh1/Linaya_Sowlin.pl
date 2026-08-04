sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings!  It is always nice to meet another traveler.  The roads of the Plains of Karana are heavily trodden, but sparsely patrolled.  Be careful of bandits and especially of giants.  I have seen a few since my [move from the Jaggedpine].");
	}
	elsif ($text=~/move from the jaggedpine/i) {
		quest::say("I inherited this farmhouse from my late uncle so I left the Jaggedpine to live here.  The Jaggedpine is a beautiful forest but I believe my skills as a druid may come in handy as a farmer.");
	}
	elsif ($text=~/note/i) {
		quest::say("The note spoke of the [Unkempt Druids]. I did not get a chance to read it all, only a glimpse. Perhaps the man still has the note. Too bad. I am sure Gerael Woodone of the druids of Surefall Glade should look at it.");
	}
	elsif ($text=~/unkempt druids/i) {
		quest::say("The Unkempt Druids are a crazed group of druids and rangers. I learned of them when I was in the Jaggedpine. They are a secret group and aim to keep it that way. They would kill anyone who learned of their whereabouts.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13945 - Flask of Nitrates
	if (plugin::check_handin(\%itemcount, 13945 => 1)) {
		quest::say("Oh thank Tunare you showed up when you did. I was at a nearby merchant house when a fellow dropped a [note] and I picked it up and read it. It talked of the [Unkempt Druids] and before I could read on, the man swiped it from my hands. I ran for dear life, for surely he would kill me for reading the note. I think I lost him in the woods but I am not sure. Please stay with me a while to be sure.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(272, 10);		#:: + Jaggedpine Treefolk
		quest::faction(302, 2);			#:: + Protectors of Pine
		quest::faction(343, 1);			#:: + Surefall Protected Animals
		quest::faction(324, -2);		#:: - Unkempt Druids
		quest::faction(262, 1);			#:: + Guards of Qeynos
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 10 to 20cp
		my %cash = plugin::RandomCash(10,20);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Spawn one and only one The Western Plains of Karana >> Draze_Slashyn (12181), no pathing grid or guild war set, at the specified location
		quest::unique_spawn(12181, 0, 0, -8000, -3400, 23, 102.9);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
