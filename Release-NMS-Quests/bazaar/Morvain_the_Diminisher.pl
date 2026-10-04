# Morvain the Diminisher - Item Tier Downgrade NPC (Guild Lobby)
# Adapted for Triptych/EQS from Ascendant-Server
#   (server/quests/guildlobby/Morvain_the_Diminisher.pl).
#
# Strips an Enchanted or Legendary item back to its base form using the EQS
# tier layout from plugins/NMS_item_utils.pl:
#     Enchanted (+1,000,000) or Legendary (+2,000,000) -> base (<1,000,000)
# Refuses if the player already owns the base item (lore conflict) or if no
# base-form item exists in the DB.

use strict;
use warnings;

our ($npc, $client, $text, %itemcount);

my $TIER_1_OFFSET   = 1000000;
my $TIER_2_OFFSET   = 2000000;
my $TIER_MAX_OFFSET = 3000000;

sub get_item_tier_info {
    my ($item_id) = @_;
    return (0, $item_id) if $item_id < $TIER_1_OFFSET;
    return (2, $item_id - $TIER_2_OFFSET) if $item_id >= $TIER_2_OFFSET && $item_id < $TIER_MAX_OFFSET;
    return (1, $item_id - $TIER_1_OFFSET) if $item_id >= $TIER_1_OFFSET && $item_id < $TIER_2_OFFSET;
    return (-1, $item_id);
}

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::Whisper(
            "I am Morvain the Diminisher. Hand me an Enchanted or Legendary item and I will strip it back to its base form.\n" .
            "If restoring it would create a lore conflict, I will refuse and return it."
        );
    }
}

sub EVENT_ITEM {
    my @valid_items = grep { $_ && $_ > 0 } keys %itemcount;

    if (scalar(@valid_items) != 1) {
        plugin::Whisper("One item at a time.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $item_id = $valid_items[0];
    my ($tier, $base_id) = get_item_tier_info($item_id);

    if ($tier <= 0) {
        plugin::Whisper("That item has no tiered ascendance for me to remove.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $base_name = quest::getitemname($base_id);
    unless ($base_name) {
        plugin::Whisper("I cannot find the original form of this item. I will not risk destroying it.");
        plugin::return_items(\%itemcount);
        return;
    }

    if ($client->CheckLoreConflict($base_id)) {
        plugin::Whisper("I will not do this. You already possess the base item and this would create a lore problem.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $attune = 0;
    my $dbh = plugin::LoadMysql();
    if ($dbh) {
        my ($attune_val) = $dbh->selectrow_array(
            "SELECT attuneable FROM items WHERE id = ?", undef, $item_id
        );
        $attune = 1 if $attune_val;
    }

    unless (quest::handin(\%itemcount)) {
        plugin::return_items(\%itemcount);
        return;
    }

    $npc->Emote("drains the ascendant power away, leaving only the item's original form.");
    $client->SummonItem($base_id, -1, $attune);
    plugin::Whisper("Done. Your item has been restored.");
}

1;
