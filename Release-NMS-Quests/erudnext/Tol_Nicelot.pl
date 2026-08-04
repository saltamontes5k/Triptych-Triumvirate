sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I have no time to waste with strangers!");
	}
	elsif ($text=~/moodoro/i) {
		quest::say("Yes, I knew Moodoro Finharn. He used to be a good friend until he started visiting Qeynos and indulging in human vices. He was executed for crimes against the state. Not even his sister [Nolusia] could get the charge dropped. There have been some who say he escaped execution and lives in Qeynos. That is insane babbling.");
	}
	elsif ($text=~/nolusia/i) {
		quest::say("Nolusia is a member of the Craftkeepers. She lives as a guildmaster in Erudin Palace.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::returnUnusedItems();
}

sub EVENT_DEATH_COMPLETE {
	quest::say("My comrades will avenge my death.");
}
