sub EVENT_DEATH_COMPLETE {
	#:: Spawn one and only one Najena >> #Rathyl_reincarnate (44104)
	quest::unique_spawn(44104, 0, 0, $x, $y, $z, $h);
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
