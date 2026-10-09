# a_revealed_skinwalker (variant 3) - "Under Your Skin" encounter.
sub EVENT_DEATH {
	my $true = $qglobals{notd_uys_true} || 0;
	if ($true == 3) {
		quest::updatetaskactivity(620016, 1, 1);
		quest::ze(15, "The true Skinwalker collapses, screaming, as its stolen skin sloughs away!");
		quest::spawn2(60020080, 0, 0, 4455, 1890, 5, 0);
	} else {
		quest::ze(15, "The skinwalker was a fake - it bursts into mist!");
		my $fakes = $qglobals{notd_uys_fakes} || 0;
		if ($fakes < 4) {
			quest::setglobal('notd_uys_fakes', $fakes + 1, 7, 'H2');
			quest::spawn2(60020077, 0, 0, 4415, 1865, 5, 0);
			quest::spawn2(60020078, 0, 0, 4445, 1835, 5, 0);
		}
	}
}
