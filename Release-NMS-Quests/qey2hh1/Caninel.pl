sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Leave me alone.");
	}
	elsif ($text=~/nachh/i) {
		quest::say("Nach and his companion Vanikk are no more than my hired guardians. Do not speak to them.");
	}
	elsif ($text=~/paw of opolla/i) {
		quest::say("What was that? The Paw of Opolla? Hmm... I might have heard of it.. But my information is valuable. I am a seeker of gems. I might offer up what I know if you were to give me three fine [jewels].");
	}
	elsif ($text=~/jewels/i) {
		quest::say("I require three jewels; a Bloodstone, a Moonstone, and a Star Rose Quartz. Only then will I tell you what I know of the rare and powerful Paw of Opolla.");
	}
	elsif ($text=~/gynok/i) {
		#:: Key a data bucket
		$key = $npc->GetNPCTypeID() . "-turned-in";
		#:: Match if data bucket exists
		if (quest::get_data($key)) {
			quest::say("Opolla's dying breath was to place a curse of poverty on the house of Moltor. Seek out the last living Moltor beneath the city of Qeynos. Be sure to ask him about the [Paw of Opolla] as well as its magic [rings]. That is all I know. Now leave me be.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 10019 - Bloodstone, a 10070 - Moonstone, and a 10021 - Star Rose Quartz
	if (plugin::check_handin(\%itemcount, 10019 => 1, 10070 => 1, 10021 => 1)) {
		quest::say("Yes. Good. You have done well. Let's see, the Paw of Opolla was it? Yes.. Opolla was once a great shaman to the Gnolls of Blackburrow. It is said she wore four enchanted rings of power. She offered her hand in peace to the first hordes of humans pouring down from the Everfrost Peaks, only to have it lopped off at the wrist by a warror named Gynok Moltor. If you seek the Paw, seek out the [decendent of Gynok].");
		#:: Key a data bucket
		$key = $npc->GetNPCTypeID() . "-turned-in";
		#:: Set the data bucket with a value of '1' that expires in 300 seconds (5 min)
		quest::set_data($key, 1, 300);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
