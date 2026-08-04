sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Well met, $name! Come in out of the cold and warm yer bones with one of my several fine house brews!  A swig o' whiskey will be sure ta put some color back inta ya!");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
