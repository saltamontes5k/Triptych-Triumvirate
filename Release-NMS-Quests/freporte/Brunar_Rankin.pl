sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("How are you? Please excuse my stench. I fish all day and night just to feed my large family. You look like an adventurer. That must be exciting. I am but a humble fisherman. Maybe someday we shall both be rich. You by your treasure and me by my catch.");
	}
	elsif ($text=~/steal from lenka/i) {
		quest::say("How dare you accuse me of being a thief!? I labor hour after hour trying to catch one fish which will bring me one copper piece to buy one slice of bread which I will split into five pieces to feed me, my sick wife and three little children, one of whom has the plague!! Poor little Repi. Now please, leave this humble little fisherman alone!");
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: When NPC arrives at 13
	if ($wp == 13) {
		quest::say("Here is my catch for today, Gregor");
		#:: Send a signal '1' to East Freeport >> Gregor_Nasin (10171) with no delay
		quest::signalwith(10171, 1, 0);
	}
	#:: When NPC arrives at waypoint 34
	elsif ($wp == 34) {
		quest::say("Ho hum, what a lovely day !");
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: When NPC arrives at waypoint 39
	elsif ($wp == 39) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	    }
	#:: When NPC arrives at waypoint 44
	elsif ($wp == 44) {
		#:: Set running true (run)
		quest::SetRunning(1);
	}
	#:: When NPC arrives at waypoint 59
	elsif ($wp == 59) {
		#:: Set running false (walk)
		quest::SetRunning(0);
	}			
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
