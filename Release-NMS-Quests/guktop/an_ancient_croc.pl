sub EVENT_DEATH_COMPLETE {
	#:: Send a signal '1' to The City of Guk >> croc_trigger (65150) with no delay
	quest::signalwith(65150, 1, 0);
}
