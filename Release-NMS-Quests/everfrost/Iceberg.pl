sub EVENT_SIGNAL {
	#:: Match a signal '1' from /everfrost/Tundra_Jack.pl
	if ($signal == 1) {
		#:: Create a scalar variable to store the entity ID of Everfrost Peaks >> Tundra_Jack (30061)
		my $tundrajack = $entity_list->GetMobByNpcTypeID(30061);
		my $follow_target = $tundrajack->GetID();
		#:: Follow at a range of 20 units
		quest::follow($follow_target, 20);
	}
}

sub EVENT_COMBAT {
	#:: Match combat_state 1 (true) for entered combat
	if ($combat_state == 1) {
		quest::say("Grrroarrr!!");
		#:: Send a signal '1' to Everfrost Peaks >> Tundra_Jack (30061) with no delay
		quest::signalwith(30061, 1, 0);
	}
	#:: Match combat_state 0 (false) for not in combat
	elsif ($combat_state == 0) {
		#:: Send a signal '3' to Everfrost Peaks >> Tundra_Jack (30061) with no delay
		quest::signalwith(30061, 3, 0);
	}
}

sub EVENT_ITEM {
	#:: Match a 12221 - Lion Delight
	if (plugin::check_handin(\%itemcount, 12221 => 1)) {
		quest::emote("growls with happiness and licks your face.  Just enough time to swipe the sweaty shirt from his collar!!  Iceberg then runs off to enjoy his lion delight!!");
		#:: Send a signal '2' to Everfrost Peaks >> Tundra_Jack (30061) with no delay
		quest::signalwith(30061, 2, 0);
		#:: Give a 12226 - Sweaty Shirt
		quest::summonitem(12226);
		#:: Ding!
		quest::ding();
		#:: Set Factions
		quest::faction(328, 2);		#:: Merchants of Halas
		quest::faction(327, 1);		#:: Shaman of Justice
		quest::faction(311, 1);		#:: Steel Warriors
		quest::faction(320, 1);		#:: Wolves of the North
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
