sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome $name. What brings you out this way? Be careful, we have had problems with bandits of late. As if the gnolls were not enough.");
	}
	elsif ($text=~/tax collection/i) {
		#:: Data bucket to verify quest has been started appropriately
		$key = $client->CharacterID() . "-tax-collection";
		#:: Match if the key exists
		if (quest::get_data($key)) {
			quest::emote("looks up with tear-filled eyes and sobs uncontrollably.");
			#:: Set faction
			quest::faction(291, -1);			#:: - Merchants of Qeynos
		}
	}
	elsif ($text=~/crying/i) {
		#:: Data bucket to verify quest has been started appropriately
		$key = $client->CharacterID() . "-tax-collection";
		#:: Match if the key exists
		if (quest::get_data($key)) {
			quest::say(".sniff.. Oh, dear. We do not have the money. We were just robbed by a dreadful halfling bandit named Flynn something-or-other. He took the money we had set asisde for Antonius. Please. Find this highwayman and retrieve our tax payment. ..sob..");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
