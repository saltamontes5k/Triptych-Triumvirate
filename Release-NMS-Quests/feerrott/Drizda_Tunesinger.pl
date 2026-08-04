sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail $name. Are you [interested] in helping the League of Antonican Bards by delivering some [mail]?");
	}
	if ($text=~/interested/i) {
		quest::say("I have messages that need to go to - well, right now I have one that needs to go to Freeport.  Will you [deliver mail to Freeport] for me?");
	}
	if ($text=~/mail/i) {
		quest::say("The League of Antonican Bards has a courier system made up of travelers and adventurers.  We pay good gold to anyone who will take messages from bards such as myself to one of our more distant offices.  Are you [interested]?");
	}
	if ($text=~/deliver mail to freeport/i) {
		quest::say("Take this letter to Felisity Starbright. You can find her at the bard guild hall. I'm sure she will compensate you for your trouble.");
		#:: Give a 18157 - Bardic Letter (Freeport)
		quest::summonitem(18157);
	}
}
