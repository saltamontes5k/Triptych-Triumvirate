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
		#:: Create a timer 'gaffin_client_check' that triggers every 60 seconds (1 min)
		quest::settimer("gaffin_client_check", 60);
		#:: Create a timer 'gaffin' that triggers every 900 seconds (15 min)
		quest::settimer("gaffin", 900);
		#:: Set the flavor text trigger state to true
		$FlavorTrigger = 1;
		quest::say("Lenny, we has a problem. Stanos is back, and he ain't happy. He told me to tell ya that he would be calling in his markers soon. I reckon ya know what that means, and that's bad business with the Circle. Whatcha wanna do?");
		#:: Send a signal '1' to Rivervale >> Lendel Deeppockets (19062) after 0 seconds
		quest::signalwith(19062, 1, 0);
	}

}

sub EVENT_TIMER {
	#:: Match timer 'gaffin_client_check'
	if ($timer eq "gaffin_client_check") {
		#:: Pull a list of clients from the entity list
		my @ClientList = $entity_list->GetClientList();
		#:: Match if the ClientList array is empty
		if (scalar @ClientList == 0) {
			#:: Set the flavor text trigger state to false
			$FlavorTrigger = 0;
			#:: Stop the timer 'gaffin'
			quest::stoptimer("gaffin");
		}
		else {
			#:: Set the flavor text trigger state to true
			$FlavorTrigger = 1;
		}
	}
	#:: Match timer 'gaffin'
	elsif ($timer eq "gaffin") {
		#:: Match if the flavor trigger state is set to true
		if ($FlavorTrigger == 1) {
			quest::say("Lenny, we has a problem. Stanos is back, and he ain't happy. He told me to tell ya that he would be calling in his markers soon. I reckon ya know what that means, and that's bad business with the Circle. Whatcha wanna do?");
			#:: Send a signal '1' to Rivervale >> Lendel Deeppockets (19062) after 0 seconds
			quest::signalwith(19062, 1, 0);
		}
		else {
			#:: Stop the timer 'gaffin'
			quest::stoptimer("gaffin");
		}
	}
}
