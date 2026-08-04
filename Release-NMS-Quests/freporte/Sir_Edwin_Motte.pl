sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name! How lucky you are to encounter the greatness of the legendary Sir Edwin Motte, slayer of cyclopes, battler of beasts, crusher of creatures, masher of monsters, eradicator of evil and champion of the third annual dart championship of Freeport.");
	}
}

sub EVENT_SIGNAL {
	#:: Match signal '1' from /freporte/Branis_Noolright.pl or /freporte/Trolon_Lightleer.pl or /freporte/Palana_Willin.pl
	if ($signal == 1) {
		quest::say("What is it with all this political revelry. Let's hear more jests!");
	}
	#:: Match signal '2' from /freporte/Branis_Noolright.pl or /freporte/Trolon_Lightleer.pl or /freporte/Palana_Willin.pl
	elsif ($signal == 2) {
		quest::say("I say, that Sir Lucan is no man of nobility. So they say...");
	}
	#:: Missing dialogue to cause this
	elsif ($signal == 3) {
		quest::say("I say!! I have fought side by side with the great Antonius bayle. He is a man of supreme virtue.");
	}
	#:: Signal From Palana Willin of East Freeport 
	elsif ($signal == 4) {
		quest::say("Bloody right, you are! Those fellows can't keep down any grog.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
