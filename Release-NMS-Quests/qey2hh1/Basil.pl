sub EVENT_SPAWN {
	#:: Set a timer "depop" to loop every 1200 seconds (20 minutes)
	quest::settimer("depop", 1200);
	#:: Set running to true (run)
	quest::SetRunning(1);
}

sub EVENT_TIMER {
	#:: Match timer "depop"
	if ($timer eq "depop") {
		quest::depop();
	}
}

sub EVENT_COMBAT {
	#:: Match if combat state is 1 (fighting)
	if ($combat_state == 1) {
		quest::say("To the death!!");
		#:: Send a signal "1" to /qey2hh1/Frostbite.pl with no delay
		quest::signalwith(12082, 1, 0);
		#:: Send a signal "1" to /qey2hh1/Frostbite.pl with no delay
		quest::signalwith(12154, 1, 0);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
