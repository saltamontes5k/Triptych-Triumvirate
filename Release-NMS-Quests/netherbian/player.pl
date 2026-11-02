# NMS: Old Man McKenzie's Derelict Space Station (netherbian v66 monster
# mission). The Derelict Space Station task (800007) tracks the three purge
# activities; #Derelict_Space_Station_Controller.lua runs the shroud and
# infestation state machine and listens for these signals. Version 0
# Netherbian Lair is untouched.
my $station_task_id    = 800007;
my $station_version    = 66;
my $station_controller = 1520001985;

sub EVENT_TASK_COMPLETE {
	return unless $client->GetZoneInstanceVersion() == $station_version;
	return unless $task_id == $station_task_id;
	quest::signal($station_controller, 1);
}

sub EVENT_DEATH {
	return unless $client->GetZoneInstanceVersion() == $station_version;
	# Silent unshroud so the bind release wakes the real character; no packets
	# here (client is on the death UI). global_player.pl is the safety net for
	# any other exit path.
	$client->RemoveShroudSilent();
	quest::signal($station_controller, 2);
}
