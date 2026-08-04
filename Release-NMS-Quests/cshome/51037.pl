sub EVENT_SPAWN {
	quest::settimer("follow",10);
}

sub EVENT_TIMER {
	if ($timer eq "follow") {
		my $OpponentID = 45000;
		my $getmobbynpctype = $entity_list->GetMobByNpcTypeID($OpponentID);
		my $follow_target = $getmobbynpctype->GetID();
		quest::follow($follow_target);
		quest::stoptimer("follow");
	}
}
