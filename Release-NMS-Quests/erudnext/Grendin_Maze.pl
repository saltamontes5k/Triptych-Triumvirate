sub EVENT_AGGRO {
	quest::say("Say hello the deities for me!!");
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
	quest::say("You have brought the vengeance of the Circle of the Unseen Hands upon yourself.");
}
