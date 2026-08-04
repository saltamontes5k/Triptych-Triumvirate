sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Duhh... uhh... hiya, $name. My name is umm... Tiny. I works here on da farm. Look out for da scarecrows. Dey will squish ya if ya tresspass in da fields.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
