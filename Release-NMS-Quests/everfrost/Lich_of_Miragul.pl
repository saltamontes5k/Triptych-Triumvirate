sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Areeeeewwwww");
	}
}

sub EVENT_ITEM {
	#:: Match 19072 - Miragul's Phylactery
	if (plugin::check_handin(\%itemcount, 19072 => 1)) {
		#:: Spawn Everfrost Peaks >> Miragul (30094), Grid 0, Guildwar 0, Current X, Current Y, Current Z, Current Heading
		quest::spawn2(30094, 0, 0, $x, $y, $z, $h);
		#:: Despawn with timer
		quest::depop_withtimer();
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

# Converted to Perl by SS
