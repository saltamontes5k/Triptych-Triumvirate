sub EVENT_SIGNAL { 
	#:: Match a signal '1' from /freportw/Krazen_Loosh.pl
	if ($signal == 1) {
		#:: Attack West Freeport >> Guard_Alayle (9141)
		quest::attacknpctype(9141); 
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
