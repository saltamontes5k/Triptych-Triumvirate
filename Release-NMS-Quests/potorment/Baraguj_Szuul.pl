sub EVENT_ENTER {
	quest::ze(14,"Baraguj Szuul lunges forward to devour his prey");
	if (!($zone->VariableExists("stomach"))){
		quest::signal(207071);
		$zone->SetVariable("stomach","1");
	}
	$client->MovePCInstance(207, $instanceid, -1094,910,-748,0);
}

sub EVENT_TIMER {
	quest::depop_withtimer();
}

sub EVENT_SPAWN {
	my $mb = $entity_list->GetMobByNpcTypeID(207028);
	$mb->SetSpecialAbility(19,1); # immune to melee
	$mb->SetSpecialAbility(20,1); # immune to magic
	$mb->SetSpecialAbility(24,1); # will not aggro
	quest::set_proximity_range(40,40,10); # set proximity range
}

sub EVENT_SIGNAL {
	if ($signal == 1) {
		# Mouth has been cleared, depop
		$zone->DeleteVariable("stomach");
		quest::settimer(1,5);
	}
}
