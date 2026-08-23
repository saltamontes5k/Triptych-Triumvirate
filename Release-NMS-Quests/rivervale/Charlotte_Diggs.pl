sub EVENT_SPAWN {
	#:: Create a scalar variable to store a random number from 1 - 720
	my $random = int(rand(720)) + 1;
	#:: Set a timer "pick" that loops every 1 - 720 seconds at random
	quest::settimer("pick",$random);
}

sub EVENT_TIMER {
	if ($timer eq "pick") {
		#:: Stop the timer "pick"
		quest::stoptimer("pick");
		quest::emote("picks up something from the ground.");
		#:: Create a scalar variable to store a random number from 1 - 720
		my $random = int(rand(720)) + 1;
		#:: Set a timer "pick" that loops every 1 - 720 seconds at random
		quest::settimer("pick",$random);	
	}
}
