sub EVENT_SPAWN {
	my $min = 1;
	my $range = 4;
	my $randomspawn = int(rand($range)) + $min;
	plugin::RandomRoam(250, 250);
	quest::settimer("move",$randomspawn);
}

sub EVENT_TIMER {
	if ($timer eq "move") {
		plugin::RandomRoam(250, 250);
	}
}
