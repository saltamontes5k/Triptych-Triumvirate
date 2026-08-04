sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Well met, $name.  I am Holly Windstalker, [Protector of the Pine].  What brings you out to the Qeynos Hills?  Not hunting, I hope. These stains on my blade are all that is left of the last adventurer I caught harming my bear and wolf friends.");
	}
	#:: Same answer on live
	elsif ($text=~/protector of pine|jaggedpine treefolk/i) {
		quest::say("The Protectors of the Pine are a group of rangers who, along with the [Jaggedpine Treefolk], protect the wild bears and wolves of Surefall Glade and its surroundings.");
	}
	elsif ($text=~/boabob|chanda|miller/i) {
		quest::say("Oh, don't you mention that name!  Baobob Miller and his sister Chanda have been nothing but trouble since they moved here from the Plains of Karana!  They only encourage people to poach out here in the hills where we can't see them.  Some even have the nerve to defy the will of Tunare and kill bears in Surefall Glade!");
	}
	elsif ($text=~/tunare/i) {
		quest::say("Tunare is the Mother of All.  It was she who cultivated the seed of humanity in the ancient soil of Norrath.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
