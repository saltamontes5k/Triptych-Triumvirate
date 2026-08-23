sub EVENT_CLICKDOOR {
	if ($doorid == 1) {
		if (quest::isdooropen(1)) {
			quest::forcedoorclose(63);
		}
		else {
			quest::forcedooropen(63);
		}
	}
	elsif ($doorid == 63) {
		if (quest::isdooropen(63)) {
			quest::forcedoorclose(1);
		}
		else {
			quest::forcedooropen(1);
		}
	}
}
