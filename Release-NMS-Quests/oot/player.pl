sub EVENT_ENTERZONE {
	if(defined $qglobals{strongbox}) { 
		quest::creategroundobject(13860, -9200, -430, -293, 0, 3000000);
		quest::delglobal("strongbox");
	}
}

sub EVENT_FISH_SUCCESS {
	if($client->GetGlobal("paladin_epic")==3) {
		if($fished_item==69914) {
			$client->Message(1,"As you reel in the dark fish's scale, you notice a large fish in the water");
			quest::depopall(69141);
			quest::spawn2(69141,0,0,-9169,265,-20.5,460); # NPC: #A_Corrupted_Koalindl
		}
	}
}

# NMS: Old Man McKenzie's Boat Lesson (oot v29 monster mission). The Boat
# Lesson task (800004) tracks the five island docks as explore activities;
# #Boat_Lesson_Controller.lua runs the shroud/ships/fail state machine and
# listens for these signals. Version 0 Ocean of Tears is untouched.
my $boat_task_id    = 800004;
my $boat_version    = 29;
my $boat_controller = 1520001940;

sub EVENT_TASK_STAGE_COMPLETE {
	return unless $client->GetZoneInstanceVersion() == $boat_version;
	return unless $task_id == $boat_task_id;
	my @dock_names = ("the Sister Isle landing", "the Mudtoe landing", "Capt. Surestout's dock", "the Aviak Isle shore", "the East Isle landing");
	my $dock = ($activity_id >= 0 && $activity_id < scalar(@dock_names)) ? $dock_names[$activity_id] : "a dock";
	quest::zone_emote(15, $client->GetCleanName() . " glides past " . $dock . ".");
}

sub EVENT_TASK_COMPLETE {
	return unless $client->GetZoneInstanceVersion() == $boat_version;
	return unless $task_id == $boat_task_id;
	quest::signal($boat_controller, 1);
}

sub EVENT_DEATH {
	return unless $client->GetZoneInstanceVersion() == $boat_version;
	# Silent unshroud so the bind release wakes the real character; no packets
	# here (client is on the death UI). global_player.pl is the safety net for
	# any other exit path.
	$client->RemoveShroudSilent();
	quest::signal($boat_controller, 2);
}
