#:: Create a scalar variable to store a state
my $FlavorTrigger;

sub EVENT_SPAWN {
	#:: Create a proximity 500 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 250, $x + 250, $y - 250, $y + 250, $z - 50, $z + 50, 0);
	#:: Set the state to false
	$FlavorTrigger = 0;
}

sub EVENT_ENTER {
	#:: Match if the flavor text has not been triggered
	if ($FlavorTrigger == 0) {
		#:: Create a timer 'mangler_client_check' that triggers every 60 seconds (1 min)
		quest::settimer("mangler_client_check", 60);
		#:: Create a timer 'mangler' that triggers every 720 seconds (12 min)
		quest::settimer("mangler", 720);
		#:: Set the flavor text trigger state to true
		$FlavorTrigger = 1;
		quest::say("<Bark, bark, bark! Hoooooowwwwwwl!>");
		#:: Send a signal '1' to Rivervale >> Kevlin_Diggs (19049) after 0 seconds
		quest::signalwith(19049, 1, 0);
	}

}

sub EVENT_TIMER {
	#:: Match timer 'mangler_client_check'
	if ($timer eq "mangler_client_check") {
		#:: Pull a list of clients from the entity list
		my @ClientList = $entity_list->GetClientList();
		#:: Match if the ClientList array is empty
		if (scalar @ClientList == 0) {
			#:: Set the flavor text trigger state to false
			$FlavorTrigger = 0;
			#:: Stop the timer 'mangler'
			quest::stoptimer("mangler");
		}
		else {
			#:: Set the flavor text trigger state to true
			$FlavorTrigger = 1;
		}
	}
	#:: Match timer 'mangler'
	elsif ($timer eq "mangler") {
		#:: Match if the flavor trigger state is set to true
		if ($FlavorTrigger == 1) {
			quest::say("<Bark, bark, bark! Hoooooowwwwwwl!>");
			#:: Send a signal '1' to Rivervale >> Kevlin_Diggs (19049) after 0 seconds
			quest::signalwith(19049, 1, 0);
		}
		else {
			#:: Stop the timer 'mangler'
			quest::stoptimer("mangler");
		}
	}
}
