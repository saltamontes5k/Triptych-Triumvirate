sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I welcome you to the temple of the Peacekeepers. The ways of peace and tranquility are ours to uphold. May you find a place among us. We have much work to do. If you are a paladin of this temple, you must [desire to face fear].");
	}
	elsif ($text=~/desire to face fear/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Very well. You shall face it. In Toxxulia Forest, you shall seek out Kerra Ridge. Once found, you will bring me the tail of a catfisher. Somehow, you shall find a way. They are weak, but they only work near the opposite side of the bridge, along the water's edge.");
		}
		else {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13884 - Fishy Cat Tail
	if (plugin::check_handin(\%itemcount, 13884 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Good work. I knew you could do it. Take this as reward.");
			#:: Give a 13053 - Brass Ring
			quest::summonitem(13053);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 5);	 		#:: + Peace Keepers
			quest::faction(266, 1); 		#:: + High Council of Erudin
			quest::faction(265, -1); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		else {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return a 13884 - Fishy Cat Tail
			quest::summonitem(13884);
		}
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}
