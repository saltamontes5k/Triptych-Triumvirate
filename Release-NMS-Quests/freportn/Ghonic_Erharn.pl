sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("May the passion of Erollisi Marr grow strong within your soul. We here in this Temple of Marr serve those who serve teh wills of Mithaniel and Erollisi Marr. If you require [healing] or curing, just let us know.");
	}
	elsif ($text=~/healing/i) {
		quest::say("It is not my duty to see to the wounded. You must seek out Plur Etinu. He is in here somewhere.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
