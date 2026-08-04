sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name - Are you [interested] in helping the League of Antonican Bards by delivering some [mail]?");
	}
	elsif ($text=~/mail/i) {
		quest::say("The League of Antonican Bards has a courier system made up of travelers and adventurers.  We pay good gold to anyone who will take messages from bards such as myself to one of our more central offices.  Are you [interested]?");
	}
	elsif ($text=~/interested/i) {
		quest::say("I have messages that need to go to - well, right now I have one that needs to go to Qeynos.  Will you deliver mail to [Qeynos] for me?");
	}
	elsif ($text=~/qeynos/i) {
		quest::say("Take this letter to Tralyn Marsinger in Qeynos.  You can find him at the bard guild hall.  I am sure he will compensate you for your troubles.");
		#:: Give item 18151 - Bardic Letter (Qeynos)
		quest::summonitem(18151);
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::returnUnusedItems();
}
