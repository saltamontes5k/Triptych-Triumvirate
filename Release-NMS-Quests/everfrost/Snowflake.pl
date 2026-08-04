sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Grrrrrr!!");
	}
	if ($text=~/megan/i) {
		quest::say("Grrroarrr !!");
		#:: Match if Amiable or better at spawn point
		if ($faction <= 4 && $x == -1161 && $y == 2022) {
			quest::say("Ruff... ruff... woof!");
			#:: Goto Megan O'reilly
			quest::start(195);
		}
		#:: Match if Indifferent at spawn point
		elsif ($faction == 5 && $x == -1161 && $y == 2022) {
			quest::emote("apparently responds only to one who follows the Wolves of the North.");
		}
		#:: Match if Apprehensive or worse at spawn point
		elsif ($faction >= 6 && $x == -1161 && $y == 2022) {
			quest::emote("growls at you. It can sense you are an enemy of the Wolves of the North.");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

# Converted to Perl by SS
