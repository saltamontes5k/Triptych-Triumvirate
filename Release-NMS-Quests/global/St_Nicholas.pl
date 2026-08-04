my $Deliveries;

sub EVENT_SPAWN {
	$Deliveries = 0;
	quest::settimer("client_check", 5);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Sorry $name, but I don't have time for you to sit on my lap right now.");
	}
}

sub EVENT_TIMER {
	if ($timer eq "client_check") {
		my @ClientList = $entity_list->GetClientList();
		if (scalar @ClientList == 0) {
			quest::stoptimer("client_check");
			quest::stoptimer("deliver_gifts");
			quest::stoptimer("roam");
			quest::depop_withtimer();
		}
		else {
			quest::stoptimer("client_check");
			quest::settimer("deliver_gifts", 90);
		}
	}
	elsif ($timer eq "deliver_gifts") {
		if ($Deliveries <= 6) {
			quest::stoptimer("deliver_gifts");
			quest::settimer("roam", 120);
			$Deliveries++;
			Give_Gifts();
		}
		else {
			quest::ze("St. Nicholas says, 'Okay kids, I have deliveries to make all over Norrath.  Up the chimney I go!'");
			quest::stoptimer("client_check");
			quest::stoptimer("deliver_gifts");
			quest::stoptimer("roam");
			quest::doanim(43);
			$npc->CastSpell(15911, $caster_id);
			quest::depop_withtimer();
		}
	}
	elsif ($timer eq "roam") {
		quest::stoptimer("roam");
		quest::settimer("deliver_gifts", 90);
		plugin::RandomRoam(250, 250);
	}
}

sub Give_Gifts {
	quest::ze(0, "St. Nicholas says, 'Ho ho ho!  Merry Christmas!'");
	quest::doanim(43);
	$npc->CastSpell(15911, $caster_id);
	my $random = int(rand(4)) + 1;
	if ($random == 4) {
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y + 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x - 5, $y + 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y - 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x - 5, $y - 5, $z - 2, 0);
	}
	elsif ($random == 3) {
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y + 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x - 5, $y + 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y - 5, $z - 2, 0);
	}
	elsif ($random == 2) {
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y + 5, $z - 2, 0);
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x - 5, $y + 5, $z - 2, 0);
	}
	elsif ($random == 1) {
		quest::creategroundobject(quest::ChooseRandom(32567, 32567, 32567, 88364), $x + 5, $y + 5, $z - 2, 0);
	}	
}
