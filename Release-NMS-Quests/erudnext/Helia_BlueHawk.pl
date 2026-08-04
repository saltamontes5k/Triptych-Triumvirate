sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello there, adventurer! I am sure you are thirsty after that long boat ride from Qeynos!");
		#:: Send a signal "1" to Erudin >> Phloatin_Highbrow (24039) with no delay
		quest::signalwith(24039, 2, 0);
	}
	elsif ($text=~/vasty deep/i) {
		quest::say("The Deepwater Knights are clerics and paladins of Prexus. They are to be found at the Deepwater Temple.");
	}
	elsif ($text=~/high council/i) {
		quest::say("The members of the High Council are the leaders of every guild within Erudin. Markus Jaevins, the leader of the Gatecallers, presides over the High Council.");
	}
	elsif ($text=~/markus jaevins/i) {
		quest::say("Markus Jaevins is the highest ranking official in Erudin.");
	}
}

sub EVENT_SIGNAL {
	#:: Match signal "1" from /erudnext/Phloatin_Highbrow.pl
	if ($signal == 1) {
		quest::say("Pipe down, Phloatin! Treat the new clientele with respect.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
