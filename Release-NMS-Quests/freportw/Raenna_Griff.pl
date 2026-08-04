sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail $name. If it is refuge you seek from the evil that is corrupting this city then I suggest you flee to Qeynos or take up arms along side the Sentries of Passion and the Knights of Truth. You must have faith that the Marr twins will not let this city fall to the hate of the Dismal Rage.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
