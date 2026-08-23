sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 14319 => 1)) {
		quest::say("Error! Malfunction! Destroy!");
		quest::say("A $class like you always brings out the worst in me.");
		#:: Spawn a The Plane of Fear >> an_enraged_golem (72106) at the current location
		quest::spawn2(72106, 0, 0, $x, $y, $z, $h);
		quest::depop_withtimer();
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' sent from /fearplane/Cazic_Thule.pl
	if ($signal == 1) {
		quest::say("Such is the will of Cazic-Thule!");
	}
	#:: Match a signal '2' sent from /fearplane/Cazic_Thule.pl
	elsif ($signal == 2) {
		my $getmobbynpctype = $entity_list->GetMobByNpcTypeID(72003);
		my $follow_target = $getmobbynpctype->GetID();
		quest::follow($follow_target);
		quest::say("We obey!");
	}
	#:: Match a signal '3' sent from /fearplane/Cazic_Thule.pl
	elsif ($signal == 3) {
		quest::sfollow();
	}
}
