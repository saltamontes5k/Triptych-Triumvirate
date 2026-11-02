# NMS: Old Man McKenzie's Midnight Snack (skyshrine v41 monster mission).
# The Midnight Snack task (800006) tracks the eat/kill activities;
# #Midnight_Snack_Controller.lua runs the shroud/cast/rage state machine and
# listens for these signals. Version 0 Skyshrine is untouched.
my $snack_task_id    = 800006;
my $snack_version    = 41;
my $snack_controller = 1520001978;

sub EVENT_TASK_COMPLETE {
	return unless $client->GetZoneInstanceVersion() == $snack_version;
	return unless $task_id == $snack_task_id;
	quest::signal($snack_controller, 1);
}

sub EVENT_DEATH {
	return unless $client->GetZoneInstanceVersion() == $snack_version;
	# Silent unshroud so the bind release wakes the real character; no packets
	# here (client is on the death UI). global_player.pl is the safety net for
	# any other exit path.
	$client->RemoveShroudSilent();
	quest::signal($snack_controller, 2);
}
