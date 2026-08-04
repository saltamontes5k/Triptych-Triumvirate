sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Rarr.  Me is Feren.  Me is fisher.  That means Feren catches [fish].");
	}
	elsif ($text=~/fish/i) {
		quest::say("All kinds of fish.  Tasty fish.  All day Feren catches the fishes so all Kerran can eat.  I do for good of all Kerran.  Rrrrr.  One thing bother Feren always though.  Is bad fish.  [Razortooth].");
	}
	elsif ($text=~/razortooth/i) {
		quest::say("Rrrrrr!  Razortooth mean fish.  Razortooth eat fish off Feren's line.  Razortooth gnaw Feren's boat.  Razortooth smart and dangerous.  Feren never able to catch Razortooth.  This haunt Feren for months.  If you was able to catch Razortooth. Feren be forever grateful. Maybe even give you possessions.");
	}
}

sub EVENT_ITEM {
	#:: Match a 6348 - Razor Tooth
	if (plugin::check_handin(\%itemcount, 6348 => 1)) {
		quest::say("Razortooth! You catch him! Truly, you be great fisher. Please take this from me. Feren is forever owing you.");
		#:: Give a 1062 - Kerran Fishingpole
		quest::summonitem(1062);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(382, 2); 	# + Kerra Isle
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
