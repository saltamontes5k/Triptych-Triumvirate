sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("stops humming to himself and turns to look at you.");
		quest::say("Ranjor tell shaddernites to gets rids of spore guardian. Ha! Gud.");
	}
	elsif ($text=~/what tune/i) {
		quest::say("Yous like da toon me hum? Me hum gud! Me hears it sumtimes when me walks by da Dark Ones place. Dey gots strong majik back dere, me gets funny feeling in me tummy.");
		#:: Spawn Grobb >> a_skeleton (52119)
		quest::spawn2(52119,0,0,-459.50,16.00,75.08,0);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
