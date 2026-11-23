my $MOUNT_COST = 5; # Triune of Fate per random mount

sub EVENT_SAY {
    my $response = "";
    my $clientName = $client->GetCleanName();

    my $link_services = "[".quest::saylink("link_services", 1, "services")."]";
    my $link_mount    = "[".quest::saylink("link_mount", 1, "a random mount")."]";
    my $link_recycle  = "[".quest::saylink("link_recycle", 1, "recycle")."]";

    if ($text =~ /hail/i) {
        $response = "Hail, $clientName! I'm Stablehand Ponyboy, tender of the finest mounts Lady Glamor's flock can offer. I can summon you a steed, though the good ones cost a bit of coin... or rather, a few Triunes of Fate. Ask about my $link_services to learn more.";
    }
    elsif ($text eq "link_services") {
        $response = "For $MOUNT_COST Triunes of Fate, I'll summon you a random mount to call your very own - a bridle or saddle you can use anytime. If it's not to your liking, hand it back and I'll $link_recycle it into something different, no fee charged! Ready to try your luck on $link_mount?";
    }
    elsif ($text eq "link_mount") {
        my $triune_available = $client->GetAlternateCurrencyValue(6);
        if ($triune_available < $MOUNT_COST) {
            $response = "I'm afraid you don't have enough Triune of Fate, $clientName. You need $MOUNT_COST to summon a mount from me. Come back when you've gathered enough.";
        } else {
            my $random_mount = get_random_mount(0, $client);
            if ($random_mount && plugin::SpendTriuneOfFate($client, $MOUNT_COST)) {
                $client->SummonItem($random_mount);
                plugin::Whisper("Enjoy your new mount, $clientName! Should it not catch your fancy, bring it back and I'll recycle it into something else for free.");
            } else {
                plugin::Whisper("How strange, $clientName. I seem to be having trouble with my flock. Please try again in a moment.");
            }
        }
    }
    elsif ($text eq "link_recycle") {
        $response = "Simply hand me any mount bridle or saddle that I gave you, and I'll swap it for a different random mount at no cost. Recycling is good for the herd, you know!";
    }

    if ($response) {
        plugin::Whisper($response);
    }
}

sub EVENT_ITEM {
    my $clientName = $client->GetCleanName();

    my $handin_mount_item = 0;
    my $handin_zone = "";
    my $dbh = plugin::LoadMysql();

    # Identify a single handed-in mount item and its mount (teleport_zone)
    foreach my $item_id (keys %itemcount) {
        next if $item_id == 0;
        my $sth = $dbh->prepare(
            "SELECT s.teleport_zone FROM items i JOIN spells_new s ON s.id = i.clickeffect
             WHERE i.id = ? AND s.teleport_zone IN (SELECT filename FROM horses) AND i.clicktype = 5 AND i.id < 1000000"
        );
        $sth->execute($item_id);
        if (my $row = $sth->fetchrow_hashref()) {
            $handin_mount_item = $item_id;
            $handin_zone = $row->{teleport_zone};
            last;
        }
    }

    if ($handin_mount_item && plugin::check_handin(\%itemcount, $handin_mount_item => 1)) {
        # Free recycling: swap for a different random mount
        my $new_mount = get_random_mount($handin_zone, $client);
        if ($new_mount) {
            plugin::Whisper("One mount traded for another, $clientName! Let's see what the herd brings you this time...");
            $client->SummonItem($new_mount);
            $dbh->disconnect();
            return;
        } else {
            plugin::Whisper("So sorry, $clientName - it seems the herd is out of new mounts at the moment. I've returned your mount to you.");
            $dbh->disconnect();
            plugin::return_items(\%itemcount);
            return;
        }
    }

    $dbh->disconnect();
    plugin::return_items(\%itemcount);
    plugin::Whisper("I don't need that, $clientName. I only trade in mount bridles and saddles, and a little Triune of Fate.");
}

# Pick one representative item per distinct mount, preferring the "Fast" variant
# when one exists. Optionally exclude a mount (its teleport_zone) for recycling.
# Delivers only mounts usable by the requesting player's class (unrestricted or
# class-matching), so class-steeds like Holy/Unholy Steed only go to their class.
sub get_random_mount {
    my $exclude_zone = shift;
    my $client = shift;
    my $class_bit = 0;
    if ($client) {
        $class_bit = $client->GetClassesBitmask() || $client->GetClassBitmask();
    }
    my $dbh = plugin::LoadMysql();

    my $sql = q{
        WITH m AS (
          SELECT i.id, s.teleport_zone, i.classes,
                 ROW_NUMBER() OVER (PARTITION BY s.teleport_zone ORDER BY (s.teleport_zone LIKE '%Fast') DESC, i.id ASC) AS rn
          FROM items i
          JOIN spells_new s ON s.id = i.clickeffect
          WHERE s.teleport_zone IN (SELECT filename FROM horses)
            AND i.clicktype = 5
            AND i.id < 1000000
        )
        SELECT id FROM m WHERE rn = 1
    };

    $sql .= " AND (classes = 65535 OR (classes & ?) > 0)";
    my @params = ($class_bit);

    if ($exclude_zone) {
        $sql .= " AND teleport_zone <> ?";
        push @params, $exclude_zone;
    }
    $sql .= " ORDER BY RAND() LIMIT 1";
    $sql .= ";";

    my $sth = $dbh->prepare($sql);
    $sth->execute(@params);

    my $id = $sth->fetchrow();
    $dbh->disconnect();
    return $id;
}

# ---------------------------------------------------------------------------
# Vendor stock rotation driver (v420/v421)
#
# Ponyboy hosts the re-roll for the three bazaar alt-currency vendors:
#   1000024 Purveyor_of_Glamour        -- weapon glamours (v420)
#   1000025 Purveyor_of_Armour_Glamour -- armour glamours (v420)
#   1000026 Stablehand_Ponyboy         -- mounts          (v421)
# The vendors' windows come purely from npc_types + merchantlist like
# Caerulea's; this only rewrites those rows and refreshes the zone's live
# lists via quest::ReloadMerchants().
#
# A re-roll fires when the boot marker differs from the one the last roll
# recorded:
#   - quests/bazaar/script_init.lua writes a fresh marker (7-day expiry) once
#     per zone process boot, so a restart produces a new marker -> re-roll;
#   - if the server stays up, the marker expires after 7 days -> the hourly
#     timer below sees an undef marker -> re-roll (the "weekly" arm);
#   - ordinary respawn cycles keep the marker stable, so they never re-roll.
# ---------------------------------------------------------------------------

my %STOCK_POOLS = (
    1000024 => 'weapon',
    1000025 => 'armour',
    1000026 => 'mounts',
);
my $STOCK_SLOT_COUNT = 20;
my $STOCK_COST       = 5;    # Triune of Fate per item (alt_currency 6)

sub EVENT_SPAWN {
    quest::stoptimer("vendor_stock");
    quest::settimer("vendor_stock", 3600);
    vendor_stock_roll_check();
}

sub EVENT_TIMER {
    return unless $timer eq "vendor_stock";
    quest::stoptimer("vendor_stock");
    quest::settimer("vendor_stock", 3600);
    vendor_stock_roll_check();
}

sub vendor_stock_roll_check {
    my $cur = quest::get_data("bazaar_boot_marker");

    # Missing marker: the 7-day expiry elapsed while the server stayed up (the
    # weekly arm), or script_init.lua's boot-time write failed. Re-arm it here
    # and treat it as a fresh roll.
    if (!defined $cur || $cur eq '') {
        $cur = time();
        quest::set_data("bazaar_boot_marker", $cur, "604800");
    }

    my $last = quest::get_data("vendor_last_roll");
    return if defined $last && $last eq $cur;    # already rolled this boot/week

    if (vendor_stock_reroll()) {
        quest::set_data("vendor_last_roll", $cur);
    }
    # on failure the marker stays unset -> the next hourly tick retries
}

sub vendor_stock_reroll {
    my $dbh = plugin::LoadMysql();
    if (!$dbh) {
        quest::debug("vendor stock roll: no database handle");
        return 0;
    }

    # Glamour pools: the cosmetic glamour namespaces (itemtype 54 aug,
    # appearance-only; mirror migration v420). Stat-bearing ornaments use
    # identity charmfiles and never match these.
    my $pool_weapon = "SELECT id, 65535 AS classes FROM items WHERE name LIKE 'Glamour - %' AND itemtype = 54 AND charmfile = 'ITEMTransAugAll' AND name NOT LIKE 'Summoned%'";
    my $pool_armour = "SELECT id, 65535 AS classes FROM items WHERE name LIKE 'Glamour - %' AND itemtype = 54 AND charmfile LIKE 'ArmorOrnLea%' AND name NOT LIKE 'Summoned%'";
    # Mounts: one representative item per distinct mount, preferring the 'Fast'
    # variant (mirrors Ponyboy's saylink roll, migration v421, minus the
    # per-player class filter -- the vendor rows gate per class instead, via
    # merchantlist.classes_required copied from each item's own classes mask).
    my $pool_mounts = "SELECT id, classes FROM (SELECT i.id, i.classes, ROW_NUMBER() OVER (PARTITION BY s.teleport_zone ORDER BY (s.teleport_zone LIKE '%Fast') DESC, i.id ASC) AS rn FROM items i JOIN spells_new s ON s.id = i.clickeffect WHERE s.teleport_zone IN (SELECT filename FROM horses) AND i.clicktype = 5 AND i.id < 1000000 AND i.classes > 0) ranked WHERE rn = 1";

    my $failed = 0;
    foreach my $merchant_id (sort { $a <=> $b } keys %STOCK_POOLS) {
        my $pool_type = $STOCK_POOLS{$merchant_id};
        my $pool_sql =
            $pool_type eq 'weapon' ? $pool_weapon :
            $pool_type eq 'armour' ? $pool_armour :
            $pool_type eq 'mounts' ? $pool_mounts :
            undef;
        unless ($pool_sql) {
            quest::debug("vendor stock roll: unknown pool for merchant $merchant_id");
            $failed = 1;
            next;
        }

        # Pick first; only touch the live rows once we actually have stock.
        my @rows;
        my $pick = $dbh->prepare("SELECT id, classes FROM ($pool_sql) stock_pool ORDER BY RAND() LIMIT $STOCK_SLOT_COUNT");
        if ($pick && $pick->execute()) {
            while (my ($id, $classes) = $pick->fetchrow_array()) { push @rows, [$id, $classes]; }
            $pick->finish();
        }
        if ($DBI::err) {
            quest::debug("vendor stock roll: pool pick failed for merchant $merchant_id: " . ($DBI::errstr || 'unknown'));
            $failed = 1;
            next;
        }
        if (!scalar @rows) {
            quest::debug("vendor stock roll: empty pool for merchant $merchant_id, leaving current stock");
            $failed = 1;
            next;
        }

        $dbh->do("DELETE FROM merchantlist WHERE merchantid = ?", undef, $merchant_id);
        my $ins = $dbh->prepare(
            'INSERT INTO merchantlist (merchantid, slot, item, faction_required, level_required, min_status, max_status, alt_currency_cost, classes_required, probability, bucket_name, bucket_value, bucket_comparison, min_expansion, max_expansion, content_flags, content_flags_disabled) VALUES (?, ?, ?, 0, 0, 0, 255, ?, ?, 100, \'\', \'\', 0, -1, -1, NULL, NULL)'
        );
        my $slot = 1;
        foreach my $row (@rows) {
            my ($item_id, $classes) = @$row;
            $ins->execute($merchant_id, $slot++, $item_id, $STOCK_COST, $classes) or $failed = 1;
        }
        $ins->finish();
        if ($DBI::err) {
            quest::debug("vendor stock roll: insert failed for merchant $merchant_id: " . ($DBI::errstr || 'unknown'));
            $failed = 1;
        }
    }

    $dbh->disconnect();
    return 0 if $failed;

    # New rows are in the DB; refresh the zone's in-memory vendor lists so the
    # next window open serves them.
    quest::ReloadMerchants();
    return 1;
}
