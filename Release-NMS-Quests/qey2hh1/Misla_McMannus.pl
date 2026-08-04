sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. You look a mite scrawny.  You should purchase some fishcakes.  They will add muscle to your frame.");
	}
	elsif ($text=~/deliver lion meat to halas/i) {
		quest::say("Very well then, here you go. Be sure to deliver this to Teria O' Danos. She will be on of the first people you meet in Halas.");
		#:: Give a 13961 - Lion Meat Shipment
		quest::summonitem(13961);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
