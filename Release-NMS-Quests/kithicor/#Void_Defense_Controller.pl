# Void Legion defense controller - Kithicor Forest (invisible).
# Runs the waves for "Out With the Old" (task 620017):
#   signal 1  = start (from A_Silly_Puppet)
#   signal 2  = wave mob died
#   signal 99 = The Legion Commander of the Void died
# Waves spawn near the Rivervale trail at ~(1068, 1250).
sub EVENT_SPAWN {
	$npc->SetEntityVariable("state", "0");
	$npc->SetEntityVariable("kills", "0");
}

sub spawn_wave1 {
	quest::ze(15, "The mist thickens - the Void Legion marches on Rivervale!");
	foreach my $s ([1040,1230],[1090,1235],[1045,1280],[1095,1275]) {
		quest::spawn2(60020082, 0, 0, $s->[0], $s->[1], 97, 0);
	}
}

sub spawn_wave2 {
	quest::ze(15, "A second wave shoulders through the mist, bloodmages chanting behind it!");
	foreach my $s ([1040,1230],[1090,1235]) { quest::spawn2(60020082, 0, 0, $s->[0], $s->[1], 97, 0); }
	foreach my $s ([1055,1250],[1080,1250]) { quest::spawn2(60020083, 0, 0, $s->[0], $s->[1], 97, 0); }
	quest::spawn2(60020084, 0, 0, 1068, 1260, 97, 0);
}

sub spawn_wave3 {
	quest::ze(15, "The mist parts - The Legion Commander of the Void has come for the trail himself!");
	quest::spawn2(60020081, 0, 0, 1068, 1270, 97, 0);
	quest::spawn2(60020084, 0, 0, 1040, 1265, 97, 0);
	quest::spawn2(60020084, 0, 0, 1095, 1265, 97, 0);
}

sub cleanup_wave {
	foreach my $tid (1500200081, 1500200082, 1500200083) {
		for (my $tries = 0; $tries < 24; $tries++) {
			my $m = $entity_list->GetNPCByNPCTypeID($tid);
			last if !$m;
			$m->Depop();
		}
	}
}

sub EVENT_SIGNAL {
	my $state = $npc->GetEntityVariable("state") || "0";
	my $kills = $npc->GetEntityVariable("kills") || "0";
	if ($signal == 1) {
		if ($state eq "0") {
			$npc->SetEntityVariable("state", "1");
			$npc->SetEntityVariable("kills", "0");
			spawn_wave1();
			quest::settimer("notd_wave", 900);
		}
	}
	elsif ($signal == 2) {
		$kills++;
		$npc->SetEntityVariable("kills", $kills);
		if ($state eq "1" && $kills >= 4) {
			quest::updatetaskactivity(620017, 0, 1);
			$npc->SetEntityVariable("state", "2");
			$npc->SetEntityVariable("kills", "0");
			spawn_wave2();
		}
		elsif ($state eq "2" && $kills >= 5) {
			quest::updatetaskactivity(620017, 1, 1);
			$npc->SetEntityVariable("state", "3");
			$npc->SetEntityVariable("kills", "0");
			spawn_wave3();
		}
	}
	elsif ($signal == 99) {
		quest::updatetaskactivity(620017, 2, 1);
		quest::ze(15, "The Legion Commander falls, and the mist recoils!");
		$npc->SetEntityVariable("state", "4");
		quest::stoptimer("notd_wave");
		cleanup_wave();
	}
}

sub EVENT_TIMER {
	if ($timer eq "notd_wave") {
		quest::stoptimer("notd_wave");
		if (($npc->GetEntityVariable("state") || "0") ne "4") {
			quest::ze(15, "The mist withdraws, taking its legion with it. The tale waits for braver souls.");
			cleanup_wave();
			$npc->SetEntityVariable("state", "0");
			$npc->SetEntityVariable("kills", "0");
		}
	}
}
