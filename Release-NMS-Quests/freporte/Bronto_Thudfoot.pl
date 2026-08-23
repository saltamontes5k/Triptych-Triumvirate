sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("How ya doin' bub. Seeing as you just joined the conversation, I think you need to buy us a round.");
	}
	elsif ($text=~/see the rogue/i) {
		quest::say("I had quite a bit of grog that night and it was very dark. What I do remember was seeing a tall woman in a dress run from the docks. She sort of smelled, too. Like fish. I know it was the docks, but this woman had a real stench to her. Like dried fish baking in the sun. That is all I remember. It was too dark to see anything but her [silhouette].");
	}
	elsif ($text=~/silhouette/i) {
		quest::say("Yeah!! The silhouette looked like a very brawny woman. It had to be a woman. The silhouette was surely that of one with a short skirt and long hair.");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal "1" from /freporte/Lenka_Stoutheart.pl
	if ($signal == 1) {
		quest::say("You said it, boss!  Stay clear of taking sides and you should be just fine, young one.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
