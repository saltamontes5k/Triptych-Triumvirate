sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings $name. I hope you are following the teachings of the Queen of Passion, Erollisi Marr. The ways of love are many and shall warm the souls of all.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	
