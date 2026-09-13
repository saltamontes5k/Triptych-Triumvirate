# The_Recharger.pl
# Bazaar item recharge NPC.
# Restores any expendable charged item to full charges for a flat 2 Triune of Fate.
# Refuses augmented items, items with no charges, and items that are already fully charged.

my $RECHARGE_COST = 2;

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::Whisper(
            "Hail, " . $client->GetCleanName() . ". Hand me a single charged item plus " .
            $RECHARGE_COST . " " . plugin::TriuneOfFateLink() . ", and I will restore it to full power. " .
            "I will not touch augmented items, items with no charges, or items that are already full."
        );
    }
}

sub EVENT_ITEM {
    # %itemcount always carries a 0 key for each empty trade slot; ignore it.
    my @item_ids = grep { $_ != 0 } keys %itemcount;

    # Only a single item, and no coin.
    if (@item_ids != 1 || $platinum || $gold || $silver || $copper) {
        plugin::Whisper("I can only recharge one item at a time, and I do not take coin.");
        return;
    }

    my $item_id = $item_ids[0];

    if ($itemcount{$item_id} != 1) {
        plugin::Whisper("I can only recharge one item at a time.");
        return;
    }

    # The item can be placed in any of the four trade slots; find the one holding it.
    my $inst;
    if    ($item1 && $item1 == $item_id) { $inst = $item1_inst; }
    elsif ($item2 && $item2 == $item_id) { $inst = $item2_inst; }
    elsif ($item3 && $item3 == $item_id) { $inst = $item3_inst; }
    elsif ($item4 && $item4 == $item_id) { $inst = $item4_inst; }

    if (!$inst) {
        plugin::Whisper("Something went wrong reading that item. Please try again.");
        return;
    }

    my $item_data = $inst->GetItem();
    if (!$item_data) {
        return;
    }

    # An item is rechargeable when it has a limited number of charges and a spell effect.
    my $max_charges = $item_data->GetMaximumCharges();
    my $has_effect  = $item_data->GetClickEffect()  > 0
                   || $item_data->GetProcEffect()   > 0
                   || $item_data->GetWornEffect()   > 0
                   || $item_data->GetScrollEffect() > 0
                   || $item_data->GetFocusEffect()  > 0;

    if ($max_charges <= 0 || !$has_effect) {
        plugin::Whisper("I cannot recharge that. Bring me an expendable charged item.");
        return;
    }

    if ($inst->IsAugmented()) {
        plugin::Whisper("I will not recharge augmented items. Remove its augments first and come back.");
        return;
    }

    if ($inst->GetCharges() >= $max_charges) {
        plugin::Whisper("That item is already fully charged.");
        return;
    }

    if (plugin::GetTriuneOfFate($client) < $RECHARGE_COST) {
        plugin::Whisper("You need " . $RECHARGE_COST . " " . plugin::TriuneOfFateLink() . " for me to recharge that.");
        return;
    }

    # Take the exact item handed in. This also removes it from the auto-return set,
    # so the player cannot keep both the original and the recharged copy.
    if (!plugin::check_handin(\%itemcount, $item_id => 1)) {
        plugin::Whisper("Something went wrong and I could not take that item.");
        return;
    }

    if (!plugin::SpendTriuneOfFate($client, $RECHARGE_COST)) {
        # Unlikely (checked just above); hand the item back so nothing is lost.
        $client->SummonFixedItem($item_id, -1);
        plugin::Whisper("Something went wrong with payment. Your item has been returned.");
        return;
    }

    # Return the exact item id (preserving tier) at full charges. SummonFixedItem is the
    # no-upgrade summon; -- do NOT use quest::summonitem / $client->SummonItem here, as those
    # route through SummonApocItem and can roll the item to a higher tier.
    $client->SummonFixedItem($item_id, -1);

    plugin::Whisper("There you go, " . $client->GetCleanName() . ". Your " . $item_data->GetName() . " is as good as new.");
}
