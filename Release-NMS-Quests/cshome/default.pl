my $FireworkTrigger;

sub EVENT_SPAWN {
	quest::set_proximity($x - 250, $x + 250, $y - 250, $y + 250, $z - 50, $z + 50, 0);
	$FireworkTrigger = 0;
}

sub EVENT_ENTER {
	if ($FireworkTrigger == 0) {
		quest::settimer("firework_client_check", 10);
		my $random = int(rand(45)) + 1;
		quest::settimer("firework", $random);
		$FireworkTrigger = 1;
		FireWorks();
	}

}

sub EVENT_TIMER {
	if ($timer eq "firework_client_check") {
		my @ClientList = $entity_list->GetClientList();
		if (scalar @ClientList == 0) {
			$FireworkTrigger = 0;
			quest::stoptimer("firework");
		}
		else {
			$FireworkTrigger = 1;
		}
	}
	elsif ($timer eq "firework") {
		if ($FireworkTrigger == 1) {
			FireWorks();
		}
		else {
			quest::stoptimer("firework");
		}
	}
}

sub FireWorks {
	my $randomspell = quest::ChooseRandom(30, 119, 206, 214, 2320, 3647, 20124..20139, 21501..21505, 21951, 24013..24016, 24069..24072, 39536..39539);
	$npc->CastSpell($randomspell, $npc->GetID());
}
