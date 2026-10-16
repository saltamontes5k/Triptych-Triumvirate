#::  CHALANDRIA'S FANG (item 43987, Legends of Norrath loot card) -- "Extract Poison"
#::
#::  Target path: NMS-Quests/global/items/script_8884.pl
#::  (items.scriptfileid 8884 -> script_8884, quest_parser_collection.cpp)
#::
#::  Live: instant click, 20-hour recast (72000 s, recast type 22). A rogue gets
#::  3 Concentrated Chalandria's Bite, anyone else 1 Chalandria's Bite, and the
#::  tier rises with level. Live does not publish the level for each tier, so we
#::  give the best tier the character can use (each poison's clicklevel). At our
#::  level cap of 65 that is tier XI, so nothing above the era is handed out.
#::  Rogue = the 3-class bitmask (HasClass), never GetClass().
#::
#::  THE ORDER OF EVENTS. EVENT_ITEM_CLICK_CAST fires BEFORE the click spell is
#::  cast, and the item's recast timer starts only when that cast lands. The RoF2
#::  click path checks the recast before this event, but the OP_CastSpell path
#::  does not, and a cast can still fail after this event (stunned, for one). So
#::  the script keeps its own 20-hour lock in a data bucket (no dot in the key:
#::  dotted bucket keys cannot expire) and also refuses while the item's own
#::  recast is running. Either way the poisons come once per 20 hours.
#::
#::  Every return is an explicit 0: this sub's value is a cast veto (see
#::  22309.pl), and a refusal here must not eat anything. The click spell itself
#::  (7651) does nothing, so letting it run is harmless.

my @BITE = (
	[12, 47657], [22, 47659], [23, 47658], [32, 47661], [33, 47660], [39, 47662],
	[42, 47663], [49, 47664], [52, 47665], [59, 47666], [60, 47667], [71, 47669],
	[75, 47668], [82, 47671], [83, 47670], [90, 52247], [93, 127051], [98, 76910],
);

my @CONCENTRATED = (
	[12, 47672], [22, 47674], [23, 47673], [32, 47676], [33, 47675], [39, 47677],
	[42, 47678], [49, 47679], [52, 47680], [59, 47681], [60, 47682], [71, 47684],
	[75, 47683], [82, 47686], [83, 47685], [90, 52248], [93, 127052], [98, 76911],
);

sub EVENT_ITEM_CLICK_CAST {
	return 0 if !$client;

	if ($client->GetBucket("lon_chalandria_fang") ne "" || $client->GetItemCooldown(43987) > 0) {
		$client->Message(15, "The fang has no venom left to give yet.");
		return 0;
	}

	my $rogue = $client->HasClass("Rogue");
	my $list  = $rogue ? \@CONCENTRATED : \@BITE;
	my $level = $client->GetLevel();
	my $pick  = 0;
	foreach my $tier (@$list) {
		$pick = $tier->[1] if $tier->[0] <= $level;
	}

	if (!$pick) {
		$client->Message(15, "The fang's venom is too potent for you yet.");
		return 0;
	}

	$client->SetBucket("lon_chalandria_fang", "1", "72000s");
	$client->SummonItem($pick, $rogue ? 3 : 1);    # the poisons have no Enchanted/Legendary rows
	return 0;
}
