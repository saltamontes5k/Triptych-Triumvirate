# an angry farmer - Misty Thicket (blessing task 700181, Quellious' Favor)
# Hand them a Strawberry-Jumjum Pie (976221) to calm them down; the pie is taken.

sub EVENT_SAY {
	return unless $text =~ /hail/i;
	if ($client->IsTaskActive(700181)) {
		quest::say("Get off my land! The Fordel ruined my crops and the Midst took my timber, and now strangers come to gawk! Unless... unless you have [" . quest::saylink("pie") . "]?");
	} else {
		quest::say("Mind your own business, stranger.");
	}
}

sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 976221 => 1)) {
		quest::say("Is...is that pie I smell? Okay, okay - first pie, then freedom!");
		$client->UpdateTaskActivity(700181, 2, 1) if $client->IsTaskActive(700181);
	}
	else {
		plugin::return_items(\%itemcount);
	}
}
