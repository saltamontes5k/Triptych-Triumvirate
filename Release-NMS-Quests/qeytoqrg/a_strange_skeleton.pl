sub EVENT_SPAWN {
	#:: Create a timer 'depop' that loops every 300 seconds (5 min)
	quest::settimer("depop",300);
	quest::say("Blast!! Another one to be tested!! My work is never done.");
}

sub EVENT_TIMER {
	#:: Match the timer 'depop'
	if ($timer eq "depop") {
		quest::depop();
	}
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You win! Well, off with my head, then!");
}
