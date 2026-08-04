sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name. You had best keep moving. One who stands around too long in Qeynos Hills tends to get surprised by vicious creatures.");
	}
	elsif ($text=~/donate/i) {
		quest::say("Why, yes! I would love to donate to the Temple of Thunder. My father was a brave and noble member of that order. Here you are. You should ask Guard Cheslin also. His father and mine are both members of Thunder. Now, move along!");
		#:: Give a 13294 - Donation
		quest::summonitem(13294);
	}
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		my $cur_target = $npc->GetHateTop();
		if ($cur_target) {
			my $target_name = $cur_target->GetCleanName();
			quest::say("Time to die " . $target_name . "!");
		}
	}
}

sub EVENT_WAYPOINT_ARRIVE {
	#:: Match waypoint 2
	if ($wp == 2) {
		#:: Do Animation 29 - Wave
		quest::doanim(29);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
