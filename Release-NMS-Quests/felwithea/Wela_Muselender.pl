sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("curtseys and says, 'Welcome to our fine tavern! Our relaxing atmosphere and pleasant wines are excellent for assisting an artist or poet in finding their muse.'");
	}
}
