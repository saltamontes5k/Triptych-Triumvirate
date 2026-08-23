sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 10 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 5, $z + 5, 0);
}

sub EVENT_ENTER {
	#:: Key a data bucket
	$key = $npc->GetID() . "-trap-sprung";
	#:: Match if the key does not exist
	if (!quest::get_data($key)) {
		quest::emote("erupts in a cloud of spores!");
		#:: Spawn a The Liberated Citadel of Runnyeye >> a_sporeling (11188)
		quest::spawn2(11188, 0, 0, $x, $y, $z, $h);
		#:: Set a data bucket with a value '1' that expires in 300 seconds
		quest::set_data($key, 1, 300);
	}
}
