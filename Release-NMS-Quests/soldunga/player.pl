#:: Forces gates to open at the same time

sub EVENT_CLICKDOOR {
	if ($doorid == 57) {
		if (quest::isdooropen(57)) {
			quest::forcedoorclose(58);
			quest::forcedoorclose(59);
		}
		else {
			quest::forcedooropen(58);
			quest::forcedooropen(59);
		}
	}
	elsif ($doorid == 58) {
		if (quest::isdooropen(58)) {
			quest::forcedoorclose(57);
			quest::forcedoorclose(59);
		}
		else {
			quest::forcedooropen(57);
			quest::forcedooropen(59);
		}
	}
	elsif ($doorid == 59) {
		if (quest::isdooropen(59)) {
			quest::forcedoorclose(58);
			quest::forcedoorclose(57);
		}
		else {
			quest::forcedooropen(58);
			quest::forcedooropen(57);
		}
	}
}
