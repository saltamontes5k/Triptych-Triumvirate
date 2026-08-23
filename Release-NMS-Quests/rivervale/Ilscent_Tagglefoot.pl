sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Oh hello, $name.  My name is Ilscent.   I am glad to see you, but I am in a bit of a [bind] right now.");
	}
	elsif ($text=~/bind/i) {
		quest::say("Well, I promised an ally of ours that I would send him a case of Jumjum juice for all the help he has given us.  I had planned on taking it to him myself but I have too many chores to do here on the farm. Will you take the [jumjum juice] to him?");
	}
	elsif ($text=~/jumjum juice/i) {
		quest::say("Oh, thank you so much!  His name is Xanuusus and he lives in the Plains of Karana, in the foothills along their northern edge, actually.  We are most grateful for your help.  Xanuusus normally rewards messengers well.");
		#:: Give a 13411 - Case of Jumjum Juice
		quest::summonitem(13411);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
