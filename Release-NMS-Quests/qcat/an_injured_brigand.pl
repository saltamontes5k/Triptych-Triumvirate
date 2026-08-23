sub EVENT_SPAWN {
	#:: Set hitpoints to half of 96
	$npc->SetHP(48);
	#:: Create a timer "injure" that loops every 5 seconds
	quest::settimer("injure", 5);
}

sub EVENT_TIMER {
	#:: Match timer "injure"
	if ($timer eq "injure") {
		$npc->SetHP(48);
	}
}

sub EVENT_COMBAT {
	#:: Match if Combat State = 1 (True - Fighting)
	if ($combat_state == 1) {
		#:: Stop the timer
		quest::stoptimer("injure");
	}
	#:: Match if Combat State = 0 (False - Not Fighting)
	elsif ($combat_state == 0) {
		#:: Create a timer "injure" that loops every 5 seconds
		quest::settimer("injure", 5);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
