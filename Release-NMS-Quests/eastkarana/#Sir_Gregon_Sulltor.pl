sub EVENT_ATTACK {
     quest::shout("You are a fool to have attacked me!");
}

sub EVENT_DEATH_COMPLETE {
     quest::shout("Evil shall never triumph over good!");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

# Converted to Perl by SS 
