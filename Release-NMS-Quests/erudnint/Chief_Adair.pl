sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. citizen!! Have you business with me? If so. please speak quickly and be on your way.");
	}
}
