# a_revealed_skinwalker (variant 1) - "Under Your Skin" encounter.
# The true one is picked in the zone qglobal notd_uys_true (1, 2 or 3).
sub EVENT_DEATH {
	my $true = $qglobals{notd_uys_true} || 0;
	if ($true == 1) {
		quest::updatetaskactivity(620016, 1, 1);
		quest::ze(15, "The true Skinwalker collapses, screaming, as its stolen skin sloughs away!");
		quest::spawn2(60020080, 0, 0, 4455, 1890, 5, 0);
	} else {
		quest::ze(15, "The skinwalker was a fake - it bursts into mist!");
		my $fakes = $qglobals{notd_uys_fakes} || 0;
		if ($fakes < 4) {
			quest::setglobal('notd_uys_fakes', $fakes + 1, 7, 'H2');
			quest::spawn2(60020078, 0, 0, 4415, 1865, 5, 0);
			quest::spawn2(60020079, 0, 0, 4445, 1835, 5, 0);
		}
	}
}
