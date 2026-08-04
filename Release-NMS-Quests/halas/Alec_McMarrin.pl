sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Removed dialogue "Just ask if you need help in finding your destination."
		quest::say("Hail, $name! I patrol Halas to insure the safety of the travelers and the resident clans.");
	}
}
	
sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
