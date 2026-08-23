sub EVENT_SPAWN {
	#:: Create a scalar variable to store a random number from 1 - 750
	my $random = int(rand(750)) + 1;
	#:: Set a timer "nilly" that loops every 1 - 750 seconds at random
	quest::settimer("nilly",$random);
}

sub EVENT_TIMER {
	#:: Create a scalar variable to store a random number from 1 - 2
	my $random_say = int(rand(2)) + 1;
	#:: Match if timer Nilly loops
	if ($timer eq "nilly") {
		#:: Match if 1
		if ($random_say == 1) {
			quest::say("Nillipuss is my name. Stealing jumjum is my game. Think you can catch me? Let's see if you can! I'll always run faster than you ever ran.");
		}
		#:: Match if 2
		else {
			quest::say("Look what I've found! What a great find! It used to be yours, but now it is mine!");
		}
	}
	#:: Stop the original timer from looping
	quest::stoptimer("nilly");
	#:: Create a scalar variable to store a random number from 1 - 750
	my $random = int(rand(750)) + 1;
	#:: Set a timer "nilly" that loops every 1 - 750 seconds at random
	quest::settimer("nilly",$random);
}
