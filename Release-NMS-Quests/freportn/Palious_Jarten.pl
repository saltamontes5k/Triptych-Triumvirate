sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("It is good to see you. $name!! Do not forget that the clerics of Mithaniel Marr are here to help those who pay tribute to Him. Should you require me to [cure disease]. just mention it.");
	}
	elsif ($text=~/cure disease/i) {
		quest::say("If you require me to cure disease. it will cost you 10 gold coins.");
	}
}

sub EVENT_ITEM {
	#:: Create a scalar variable for storing money
	my $cash = 0;
	$cash = ($platinum * 1000) + ($gold * 100) + ($silver * 10) + $copper;
	#:: Match 1000 copper - 10gp
	if ($cash == 1000) {
		#:: Cast spell 213 - Cure Disease
		$npc->CastSpell(213,$userid);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
