sub EVENT_SAY {
	if ($text=~/some ink/i) {
		quest::say("Jinkus must've sent ye fer some of me special ink made from the pigement of th' dalura flower.  Ye may take some free o' charge as a donation to the church and to the will of the Tribunal as well.");
		#:: Give a 12619 - Vial of Datura Ink
		quest::summonitem(12619);
	}
	elsif ($text=~/shaman of justice/i) {
		quest::say("The Shamans of Justice serve the will of the Tribunal. They search out those who defy the laws set by the Tribunal.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
