sub EVENT_SPAWN {
	#:: Create a timer 'keeper_spawn' that triggers every 3600 - 5100 seconds (60 to 85 minutes)
	quest::settimer("keeper_spawn", int(rand(1500)) + 3600);
	quest::gmsay("Keeper Spawn Timer Started");
}

sub EVENT_TIMER {
	#:: Match timer 'keeper_spawn'
	if ($timer eq "keeper_spawn") {
		quest::stoptimer("keeper_spawn");
		#:: Spawn a The Plane of Sky >> Keeper_of_Souls (71075), without grid or guild war, at the specified location
		quest::spawn2(71075, 0, 0, -996.3, 910.5, 192.3, 18.0);
		#:: Depop without spawn timer
		quest::depop();
	}
}
