# NMS: Old Man McKenzie's King of the Monsters (moors v40 monster mission).
# The King of the Monsters task (800005) tracks the six devour-per-color
# activities; #King_of_the_Monsters_Controller.lua runs the shroud/prey/fail
# state machine and listens for these signals. Version 0 Blightfire Moors is
# untouched.
my $hunt_task_id    = 800005;
my $hunt_version    = 40;
my $hunt_controller = 1520001970;

sub EVENT_TASK_COMPLETE {
	return unless $client->GetZoneInstanceVersion() == $hunt_version;
	return unless $task_id == $hunt_task_id;
	quest::signal($hunt_controller, 1);
}

sub EVENT_DEATH {
	return unless $client->GetZoneInstanceVersion() == $hunt_version;
	# Silent unshroud so the bind release wakes the real character; no packets
	# here (client is on the death UI). global_player.pl is the safety net for
	# any other exit path.
	$client->RemoveShroudSilent();
	quest::signal($hunt_controller, 2);
}
