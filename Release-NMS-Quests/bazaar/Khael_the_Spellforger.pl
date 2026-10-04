# Khael the Spellforger - Item Tier Upgrade NPC (Guild Lobby)
# Adapted for Triptych/EQS from Ascendant-Server
#   (server/quests/guildlobby/Khael_the_Spellforger.pl).
#
# Consumes one Ancient Shard of Ascendant Power (121856) + one item and attempts
# to raise it to the next EQS tier:
#     base (<1,000,000) -> Enchanted (+1,000,000)   70% success
#     Enchanted         -> Legendary (+2,000,000)   50% success
# On failure the shard is lost but the item is returned.
# Tier layout follows plugins/NMS_item_utils.pl (Tier0/Tier1/Tier2).

use strict;
use warnings;

our ($npc, $client, $text, %itemcount, $popupid);

my $SHARD_ID         = 121856;
my $TIER_1_OFFSET    = 1000000;   # Enchanted
my $TIER_2_OFFSET    = 2000000;   # Legendary
my $TIER_MAX_OFFSET  = 3000000;   # ids >= this are treated as untierable
my $CHANCE_BASE_TO_T1 = 70;
my $CHANCE_T1_TO_T2   = 50;

sub get_item_tier_info {
    my ($item_id) = @_;
    return (0, $item_id) if $item_id < $TIER_1_OFFSET;
    return (2, $item_id - $TIER_2_OFFSET) if $item_id >= $TIER_2_OFFSET && $item_id < $TIER_MAX_OFFSET;
    return (1, $item_id - $TIER_1_OFFSET) if $item_id >= $TIER_1_OFFSET && $item_id < $TIER_2_OFFSET;
    return (-1, $item_id);   # beyond the EQS tier range
}

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::Whisper(
            "I am Khael the Spellforger. I force ancient ascendant power into items using shards long lost to time.\n\n" .
            "If you possess an Ancient Shard of Ascendant Power, I may attempt an infusion.\n\n" .
            "Say " . quest::saylink("details", 1) . " if you wish to understand the risks."
        );
    }
    elsif ($text =~ /details/i) {
        my $popup = "<c \"#FFD700\">\x{2692} Khael the Spellforger \x{2692}</c><br><br>"
            . "I use ancient spellcraft to <b>force ascendant power</b> into mortal items. This process is unstable.<br><br>"
            . "<c \"#00FFFF\"><b>Requirements</b></c><br>"
            . "&bull; One <c \"#FFD700\">Ancient Shard of Ascendant Power</c><br>"
            . "&bull; One item to infuse<br><br>"
            . "<c \"#00FFFF\"><b>Upgrade Paths</b></c><br>"
            . "Base &rarr; <c \"#00CCFF\">Enchanted</c> (70%)<br>"
            . "<c \"#00CCFF\">Enchanted</c> &rarr; <c \"#CC66FF\">Legendary</c> (50%)<br><br>"
            . "<c \"#00FF00\"><b>Success</b></c><br>&bull; Item ascends to the next tier<br>&bull; Shard is consumed<br><br>"
            . "<c \"#FF9900\"><b>Failure</b></c><br>&bull; Shard is destroyed<br>&bull; Item is returned intact<br><br>"
            . "<c \"#FF5555\"><b>Warning</b></c><br>Ancient power is finite. Not all shards endure the binding.";
        $client->Popup2("Khael the Spellforger", $popup, 0, 0, 0, 0);
    }
}

sub EVENT_ITEM {
    my @valid_items = grep { $_ && $_ > 0 } keys %itemcount;

    my $shard_count = $itemcount{$SHARD_ID} || 0;
    my $total_items = 0;
    $total_items += ($itemcount{$_} || 0) for @valid_items;

    unless (scalar(@valid_items) == 2 && $shard_count == 1 && $total_items == 2) {
        plugin::Whisper("I require exactly one Ancient Shard and one item to attempt an infusion. Nothing more, nothing less.");
        plugin::return_items(\%itemcount);
        return;
    }

    my ($other_item_id) = grep { $_ != $SHARD_ID } @valid_items;
    unless ($other_item_id) {
        plugin::return_items(\%itemcount);
        return;
    }

    my ($current_tier, $base_id) = get_item_tier_info($other_item_id);

    if ($current_tier < 0) {
        plugin::Whisper("The shard finds no path forward for this item.");
        plugin::return_items(\%itemcount);
        return;
    }
    if ($current_tier == 2) {
        plugin::Whisper("This item radiates with such intensity that I dare not touch it. It cannot be improved further.");
        plugin::return_items(\%itemcount);
        return;
    }

    # Look the upgrade path up in the database (canonical tier helper) rather
    # than the shared-memory item cache, which can lag behind newly added items.
    my @upgrades = plugin::GetUpgrades($base_id);

    my ($target_id, $chance);
    if ($current_tier == 0) {
        $target_id = $upgrades[1];
        $chance    = $CHANCE_BASE_TO_T1;
    }
    else {
        $target_id = $upgrades[2];
        $chance    = $CHANCE_T1_TO_T2;
    }

    if (!$target_id || $target_id == $other_item_id) {
        plugin::Whisper("This item refuses the shard's power. It does not seem to have an ascendant form.");
        plugin::return_items(\%itemcount);
        return;
    }

    if ($client->CountItem($target_id) > 0) {
        plugin::Whisper("I will not attempt this infusion. You already possess the resulting item, and the lore would reject it.");
        plugin::return_items(\%itemcount);
        return;
    }

    unless (plugin::check_handin(\%itemcount, $SHARD_ID => 1, $other_item_id => 1)) {
        plugin::return_items(\%itemcount);
        return;
    }

    my $roll = int(rand(100)) + 1;

    if ($roll <= $chance) {
        $npc->Emote("channels raw magical energy into the item... it glows with a blinding light!");
        $client->SummonItem($target_id);
        plugin::Whisper("Success! The ascendant power has taken hold.");
    }
    else {
        $npc->Emote("channels raw magical energy... but the power destabilizes and dissipates!");
        $client->SummonItem($other_item_id);
        plugin::Whisper("Failure. The shard has shattered, but your item remains intact.");

        my $charid  = $client->CharacterID();
        my $fail_key = "leaderboard_upgrade_fails_${charid}";
        my $fails = int(quest::get_data($fail_key) || 0) + 1;
        quest::set_data($fail_key, $fails);

        my $name = $client->GetCleanName();
        if ($fails == 100) {
            quest::enabletitle(414);
            quest::we(15, "$name has failed 100 item upgrades at Khael the Spellforger. They are officially unlucky!");
        }
        elsif ($fails == 200) {
            quest::enabletitle(415);
            quest::we(15, "$name has failed 200 item upgrades at Khael the Spellforger. Their bad luck is becoming legendary!");
        }
        elsif ($fails == 350) {
            quest::enabletitle(412);
            quest::enabletitle(413);
            quest::we(15, "$name has failed 350 item upgrades at Khael the Spellforger. They have experienced a truly legendary amount of failure!");
        }
    }

    plugin::return_items(\%itemcount);
}

1;
