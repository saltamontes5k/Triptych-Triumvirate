sub EVENT_SPAWN {
	#:: Create a timer for 6 hours
	quest::settimer("depop",21600);
}

sub EVENT_TIMER {
	if ($timer eq "depop") {
		#:: Enable spawn point for North Kaladim >> Harnoff_Splitrock (67057)
		quest::enable_spawn2(67057);
		#:: Depop
		quest::depop();
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetins to ya friend Dwarf! I've got some of the finest quality steel ores in all the lands!");
	}
}

sub EVENT_ITEM {
  	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	#:: Enable spawn point for North Kaladim >> Harnoff_Splitrock (67057)
	quest::enable_spawn2(67057);
}
