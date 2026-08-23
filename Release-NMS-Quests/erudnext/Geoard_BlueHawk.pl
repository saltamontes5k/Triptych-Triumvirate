sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, adventurer! After all those months of sweaty, hot and dirty battling of beasts untold, it is time to treat yourself to a tall, cool grog!");
	}
	elsif ($text=~/erud's tonic/i) {
		quest::say("Long ago, the great Erud found that excessive indulgence in spirits led to diminished mental awareness. His love of Kaladim brandy led him to concoct Erud's Tonic. The tonic blocked the effects of all spirits. Unfortunately, it is made from our precious [Vasty Deep Water] and therefore is not permitted to be exported or given to non-Erudites or adventuring Erudites.");
	}
	elsif ($text=~/have some/i) {
		quest::say("The sale or provision of Erud's Tonic to travelers is prohibited!");
		#:: Send signal "1" to erudnext/Phloatin_Highbrow.pl with no delay
		quest::signalwith(24039, 1, 0);
	}
	elsif ($text=~/vasty deep/i) {
		quest::say("The Vasty Deep is a lake located on Odus. It contains the purest water in Norrath. Some say it is magical in nature. The High Council does not allow it to be taken by outsiders and those who try are usually converted to chum for the sharks.");
	}
	elsif ($text=~/high council/i) {
		quest::say("The members of the High Council are the leaders of every guild within Erudin. Markus Jaevins, the leader of the Gatecallers, presides over the High Council.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
