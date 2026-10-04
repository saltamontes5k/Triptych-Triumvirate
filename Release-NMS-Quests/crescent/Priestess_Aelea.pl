#generic soulbinder quest
sub EVENT_SAY {
	plugin::soulbinder_say($text);
	# Freeing Kaldimar (600567)
	if ($text=~/kaldimar/i) {
		if (!quest::istaskactive(600567) && !quest::istaskcompleted(600567)) {
			quest::say("You know of [Kaldimar], then - the drakkin taken by the Nokk, held below the Reach while his captors work their will. Ten soldiers guard him, and an assassin keeps the watch. Free him.");
			quest::assigntask(600567);
		}
		elsif (quest::istaskactive(600567)) {
			quest::say("Ten Nokk soldiers, and the assassin that keeps their watch. Kaldimar waits below.");
		}
		else {
			quest::say("Kaldimar is free, and the temple lights a candle for you each dawn.");
		}
	}
}