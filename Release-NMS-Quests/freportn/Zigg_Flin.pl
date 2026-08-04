sub EVENT_SAY {
	#:: Match if faction is Kindly or better
	if ($faction <= 2) {
		quest::say("Hello, $name, My name is Zigg.");
	}
	#:: Match if faction is Indifferent or better
	elsif ($faction <= 5) {
		my $RandomResponse = quest::ChooseRandom(1, 2, 3, 4, 5, 6, 7);
		if ($RandomResponse == 1) {
			quest::say("I think I saw a gnoll pup you could probably defeat, a few miles back.");
		}
		elsif ($RandomResponse == 2) {
			quest::say("This matter is far too advanced for you to handle..come back after you've slayed a few more large rats boy.");
		}
		elsif ($RandomResponse == 3) {
			quest::say("It's much safer for you to spend time fishing than on a dangerous issue like this.");
		}
		elsif ($RandomResponse == 4) {
			quest::say("I'm not sure I can entrust you with this information yet.");
		}
		elsif ($RandomResponse == 5) {
			quest::say("Your loyalty to our ideals has yet been proven.");
		}
		elsif ($RandomResponse == 6) {
			quest::say("Come back when you have done more to further our campaign.");
		}
		elsif ($RandomResponse == 7) {
			quest::say("You need to prove your dedication to our cause before I can discuss such matters with you.")
		}
	}
	else {
		my $RandomResponse = quest::ChooseRandom(1, 2, 3, 4);
		if ($RandomResponse == 1) {
			quest::say("Oh look, a talking lump of refuse. How novel!");
		}
		elsif ($RandomResponse == 2) {
			quest::say("I wonder how much I could get for the tongue of a blithering fool? Leave before I decide to find out for myself.");
		}
		elsif ($RandomResponse == 3) {
			quest::say("I didn't know Slime could speak common. Go back to the sewer before I lose my temper.");
		}
		elsif ($RandomResponse == 4) {
			quest::say("Is that your BREATH, or did something die in here? Now go away!");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
