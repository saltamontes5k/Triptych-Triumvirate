sub EVENT_SPAWN {
	my $min = 1;
	my $range = 4;
	my $randomspawn = int(rand($range)) + $min;
	quest::settimer("move",$randomspawn);
}

sub EVENT_TIMER {
	if ($timer eq "move") {
		plugin::RandomRoam(500, 500, 25);
	}
}
