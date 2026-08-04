#:: Create a scalar variable to store the number of spawned crocs.
my $CrocsUp = 0;

sub EVENT_SPAWN {
	#:: Run the SpawnCrocs sub routine
	SpawnCrocs();
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /guktop/a_saltwater_croc.pl or /guktop/an_ancient_croc.pl
	if ($signal == 1) {
		$CrocsUp--;
		if ($CrocsUp == 0) {
			quest::settimer("crocspawn", 640);
		}
	}
}

sub EVENT_TIMER {
	#:: Match the timer 'crocspawn'
	if ($timer eq "crocspawn") {
		#:: Stop the timer 'crocspawn' from looping
		quest::stoptimer("crocspawn");
		#:: Run the SpawnCrocs sub routine
		SpawnCrocs();
	}
}

sub SpawnCrocs {
	my $SpawnCroc = quest::ChooseRandom(65068, 65069, 65094, 65095, 65134);
	my $SpawnChance = plugin::RandomRange(1, 100);

	if ($SpawnChance <= 45) {
		quest::spawn2($SpawnCroc, 0, 0, 470, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 462, 1653, -70, 66);
		$CrocsUp = 2;
	}
	elsif ($SpawnChance > 45 && $SpawnChance <= 75) {
		quest::spawn2($SpawnCroc, 0, 0, 470, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 462, 1653, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 450, 1661, -70, 66);
		$CrocsUp = 3;
	}
	elsif ($SpawnChance > 75 && $SpawnChance <= 90) {
		quest::spawn2($SpawnCroc, 0, 0, 470, 1661, -70, 66);
		$CrocsUp = 1;
	}
	elsif ($SpawnChance > 90 && $SpawnChance <= 95) {
		quest::spawn2(65139, 0, 0, 462, 1653, -70, 66);
		$CrocsUp = 1;
	}
	elsif ($SpawnChance > 95 && $SpawnChance <= 98) {
		quest::spawn2($SpawnCroc, 0, 0, 470, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 462, 1653, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 450, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 459, 1671, -70, 66);
		$CrocsUp = 4;
	}
	elsif ($SpawnChance > 98) {
		quest::spawn2($SpawnCroc, 0, 0, 470, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 462, 1653, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 450, 1661, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 459, 1671, -70, 66);
		quest::spawn2($SpawnCroc, 0, 0, 480, 1667, -70, 66);
		$CrocsUp = 5;
	}
}
