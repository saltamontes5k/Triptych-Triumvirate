sub EVENT_SPAWN {
	#:: Create a proximity, 40 units across, 20 units tall, without proximity say
	quest::set_proximity($x - 20, $x + 20, $y - 20, $y + 20, $z - 10, $z + 10, 0);
}

sub EVENT_EXIT {
	if ($npc->IsOnHatelist($client)) {
		$npc->RemoveFromHateList($client)
	}
}
