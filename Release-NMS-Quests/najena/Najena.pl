sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Time to die $name!");
		#:: Create a scalar variable to store a random number from 1 - 4
		my $random_say = int(rand(4)) + 1;
		if ($random_say == 1) {
			quest::say("It's $race" . "s like you who have ruined your own lands.  You'll not ruin mine!");
		}
		elsif ($random_say == 2) {
			quest::say("Filthy $race" . "s like you must die!");
		}
		elsif ($random_say == 3) {
			quest::say("$race" . "s like you are better left dead than alive!");
		}
		elsif ($random_say == 4) {
			quest::say("$race" . "s have no place in our realm!");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
