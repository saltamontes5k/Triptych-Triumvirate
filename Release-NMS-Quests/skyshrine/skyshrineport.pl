$instanceid = quest::GetInstanceID();

sub EVENT_SPAWN {
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 40, $z + 40);
}

sub EVENT_ENTER {
	$client->MovePCInstance(114, $instanceid, 1371, 2738, -160, 60);
}


