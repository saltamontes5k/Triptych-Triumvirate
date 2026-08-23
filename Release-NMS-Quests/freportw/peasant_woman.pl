sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("grunts as she tries to fill two buckets of [water]. Her frail arms strain at her work and pain fills her eyes with tears.");
	}
	elsif ($text=~/take this water to him/i) {
		quest::say("Surely you are a pure soul. If you would take this bucket of water to my brother, I would be forever grateful. I am just so tired, I need to rest... She slumps to the floor and begins to breathe shallowly, in short, harsh gasps.");
		#:: Give item 29008 - Bucket of Water
		quest::summonitem(29008);
	}
	elsif ($text=~/water/i) {
		quest::say("Aye, water, m'lord. For my brother. He is very sick. He's needin' drink. He's burnin' up. I am sick myself but still able to move, a little. I must [take this water to him] before he gets worse.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
