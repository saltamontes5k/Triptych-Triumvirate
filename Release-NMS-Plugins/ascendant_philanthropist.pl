# ascendant_philanthropist.pl - Philanthropist NPC Plugin
# Author: Straps
#
# Core logic for the Ben Affactor philanthropist system.
# Distribution timer runs on the NPC; pickup runs per-player from global_player.pl.

# ============================================================
# CONFIG
# ============================================================
my $POOL_THRESHOLD    = 5000;    # minimum pool pp to trigger distribution
my $TIMER_MIN         = 2700;     # 45 minutes
my $TIMER_MAX         = 10800;    # 3 hours
my $DAILY_CAP_PP      = 5000;     # max pp receivable per character per day
my $PICKUP_LIMIT      = 5;        # max grants processed per timer tick
my $RECIP_MAX_LVL     = 51;
my $RECIP_MAX_PLAY    = 900;      # 15 hours in minutes
my @EXCLUDED_ZONES    = (151, 344);    # bazaar, guildlobby
my $ONLINE_WINDOW     = 600;           # seconds — last_login within 10 min = online

# ============================================================
# Philanthropist_RandomDelay() — random seconds between TIMER_MIN and TIMER_MAX
# ============================================================
sub Philanthropist_RandomDelay {
    return $TIMER_MIN + int(rand($TIMER_MAX - $TIMER_MIN + 1));
}

# ============================================================
# Philanthropist_RunDistribution() — check pool, allocate, broadcast
# Called from Ben_Affactor EVENT_TIMER (instance 0 only, single caller)
# ============================================================
sub Philanthropist_RunDistribution {
    my $dbh = plugin::LoadMysql();
    return unless $dbh;

    # Check pool total
    my ($pool_total) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0) FROM philanthropist_pool WHERE distributed = 0"
    );
    return if $pool_total < $POOL_THRESHOLD;

    # Gather donor names
    my $dn_sth = $dbh->prepare(
        "SELECT DISTINCT donor_name FROM philanthropist_pool WHERE distributed = 0 ORDER BY id ASC"
    );
    $dn_sth->execute();
    my @donors;
    while (my $r = $dn_sth->fetchrow_hashref()) { push @donors, $r->{donor_name}; }
    $dn_sth->finish();
    return unless scalar(@donors) > 0;

    # Get eligible recipients (1 per account, deterministic lowest char id)
    my $rq = $dbh->prepare(
        "SELECT cd.id AS character_id, cd.name, cd.account_id "
        . "FROM character_data cd "
        . "INNER JOIN ("
        . "  SELECT account_id, MIN(id) AS pick_id"
        . "  FROM character_data"
        . "  WHERE level < $RECIP_MAX_LVL"
        . "  AND time_played < $RECIP_MAX_PLAY"
        . "  AND last_login > (UNIX_TIMESTAMP() - $ONLINE_WINDOW)"
        . "  AND zone_id NOT IN (" . join(",", @EXCLUDED_ZONES) . ")"
        . "  AND deleted_at IS NULL"
        . "  GROUP BY account_id"
        . ") sub ON cd.id = sub.pick_id"
    );
    $rq->execute();
    my @recipients;
    while (my $r = $rq->fetchrow_hashref()) { push @recipients, $r; }
    $rq->finish();
    return if scalar(@recipients) == 0;

    # Check daily caps
    my @eligible;
    foreach my $r (@recipients) {
        my ($received) = $dbh->selectrow_array(
            "SELECT COALESCE(SUM(amount), 0) FROM pending_plat_grants "
            . "WHERE character_id = ? AND DATE(created_at) = CURDATE()",
            undef, $r->{character_id}
        );
        my $remaining = $DAILY_CAP_PP - $received;
        if ($remaining > 0) {
            $r->{remaining} = $remaining;
            push @eligible, $r;
        }
    }
    return if scalar(@eligible) == 0;

    # Allocation loop with redistribution
    my $pool_left = $pool_total;
    my %grants;

    while ($pool_left > 0 && scalar(@eligible) > 0) {
        my $share = int($pool_left / scalar(@eligible));
        last if $share <= 0;
        my @still;
        foreach my $r (@eligible) {
            my $grant = ($share < $r->{remaining}) ? $share : $r->{remaining};
            $grants{$r->{character_id}} = ($grants{$r->{character_id}} || 0) + $grant;
            $r->{remaining} -= $grant;
            $pool_left -= $grant;
            push @still, $r if $r->{remaining} > 0;
        }
        @eligible = @still;
    }

    # Format donor names (Oxford comma)
    my $donor_str;
    if (scalar(@donors) == 1) {
        $donor_str = $donors[0];
    } elsif (scalar(@donors) == 2) {
        $donor_str = "$donors[0] and $donors[1]";
    } else {
        my @d = @donors;
        my $last = pop @d;
        $donor_str = join(", ", @d) . ", and $last";
    }

    # Insert pending grants
    my $ins = $dbh->prepare(
        "INSERT INTO pending_plat_grants (character_id, amount, donor_names) VALUES (?, ?, ?)"
    );
    my $recip_count = 0;
    foreach my $cid (keys %grants) {
        next unless $grants{$cid} > 0;
        $ins->execute($cid, $grants{$cid}, $donor_str);
        $recip_count++;
    }
    $ins->finish();

    # Mark pool rows as distributed
    $dbh->do("UPDATE philanthropist_pool SET distributed = 1 WHERE distributed = 0");

    # World broadcast
    quest::we(14, "The benevolence of $donor_str has blessed $recip_count adventurer"
        . ($recip_count != 1 ? "s" : "")
        . " with platinum to aid them on their journey!");
}

# ============================================================
# Philanthropist_HandleItemDonation($client, \%itemcount, \%attuned) — validate + pool gear
# Called from Ben_Affactor EVENT_ITEM; stores accepted gear for The Provisioner
# ============================================================
# Beneficial stat columns that make an item "real gear". AC is deliberately
# excluded so AC-only vendor trash and damage-only weapons are rejected.
my @PHIL_GEAR_STATS = qw(
    hp mana astr asta aagi adex aint awis acha
    cr dr fr mr pr svcorruption
    heroic_str heroic_int heroic_wis heroic_agi heroic_dex heroic_sta
    heroic_cha heroic_mr heroic_fr heroic_cr heroic_pr heroic_dr heroic_svcorrup
    attack accuracy avoidance shielding spellshield strikethrough stunresist
    dotshielding dsmitigation damageshield regen manaregen enduranceregen
    clairvoyance healamt spelldmg backstabdmg haste skillmodvalue
);

sub Philanthropist_GearStatValue {
    my ($row) = @_;
    return 0 unless $row;
    my $sum = 0;
    foreach my $col (@PHIL_GEAR_STATS) {
        $sum += ($row->{$col} || 0);
    }
    return $sum;
}

sub Philanthropist_HandleItemDonation {
    my ($client, $itemcount_ref, $attuned_ref) = @_;
    my $donor_name = $client->GetCleanName();
    my $dbh = plugin::LoadMysql();

    if (!$dbh) {
        plugin::Whisper("Something went wrong. Your items have been returned.");
        return;
    }

    my $pooled_level0 = 0;

    foreach my $item_id (keys %$itemcount_ref) {
        next unless $item_id && $item_id > 0;
        my $qty = $itemcount_ref->{$item_id} || 1;
        my $item_link = quest::varlink($item_id);

        my $row = $dbh->selectrow_hashref("SELECT * FROM items WHERE id = ?", undef, $item_id);
        my $nodrop_val = $row ? $row->{nodrop} : undef;

        # Reject inherently no-drop items (nodrop: 0 = NO TRADE, 1 = tradeable)
        if (!defined($nodrop_val) || $nodrop_val == 0) {
            quest::debug("[Philanthropist] Rejecting no-trade item $item_id qty=$qty");
            plugin::Whisper("I can't accept no-trade items. Returning your $item_link.");
            for (my $i = 0; $i < $qty; $i++) { $client->SummonItem($item_id); }
            next;
        }

        # Reject items already attuned to this character (instance-level no-drop)
        if ($attuned_ref && $attuned_ref->{$item_id}) {
            quest::debug("[Philanthropist] Rejecting attuned item $item_id qty=$qty");
            plugin::Whisper("That item is already attuned and bound to you. Returning your $item_link.");
            for (my $i = 0; $i < $qty; $i++) { $client->SummonItem($item_id, -1, 1); }  # attune=true
            next;
        }

        my $reqlevel = ($row->{reqlevel} || 0);
        my $stat_value = Philanthropist_GearStatValue($row);

        # Reject summoned items (e.g. magician conjurations). Note: norent is
        # unusable here -- nearly every item in this DB has norent=1.
        if ($row->{summonedflag} || ($row->{Name} && $row->{Name} =~ /^Summoned:/i)) {
            quest::debug("[Philanthropist] Rejecting summoned/temporary item $item_id");
            plugin::Whisper("I can't take summoned or temporary items. Returning your $item_link.");
            for (my $i = 0; $i < $qty; $i++) { $client->SummonItem($item_id); }
            next;
        }

        my $is_gear = ($row->{slots} && $row->{slots} != 0)
            && (($row->{itemclass} || 0) == 0)
            && !($row->{stackable})
            && !($row->{bagslots})
            && ($stat_value > 0);

        # Only real, equippable stat gear (not bags/books/stackables/containers,
        # and not AC-only or damage-only junk such as rusty weapons).
        if (!$is_gear) {
            quest::debug("[Philanthropist] Rejecting non-gear item $item_id");
            plugin::Whisper("I only take real gear with stat bonuses for adventurers, not $item_link. Returning it.");
            for (my $i = 0; $i < $qty; $i++) { $client->SummonItem($item_id); }
            next;
        }

        # Consume each copy and add it to the adventurer gear pool.
        my $accepted = 0;
        for (my $i = 0; $i < $qty; $i++) {
            last unless quest::handin({$item_id => 1});
            $accepted++;
        }

        if ($accepted > 0) {
            my $ins = $dbh->prepare(
                "INSERT INTO philanthropist_item_pool "
                . "(item_id, quantity, reqlevel, classes, races, slots, stat_value, donor_char_id, donor_account_id, donor_name) "
                . "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );
            $ins->execute(
                $item_id, $accepted, $reqlevel,
                ($row->{classes} || 0), ($row->{races} || 0), ($row->{slots} || 0), $stat_value,
                $client->CharacterID(), $client->AccountID(), $donor_name
            );
            $ins->finish();

            $pooled_level0 += $accepted if ($reqlevel == 0);

            plugin::Whisper("Thank you, $donor_name. Your $item_link has been added to my stores for adventurers who need it.");
        }
    }

    # Feed the server-wide Triune blessing counter (4 level-0 pieces = +2h).
    if ($pooled_level0 > 0) {
        plugin::TriuneBlessing_AddDonation($client, 0, $pooled_level0);
    }
}

# ============================================================
# Adventurer gear pool helpers (used by The Provisioner in the Bazaar)
# ============================================================

# Bitmask of empty equipment slots (Charm..Ammo = 0..22).
sub Philanthropist_EmptyEquipMask {
    my ($client) = @_;
    my $mask = 0;
    for my $slot (0 .. 22) {
        my $item = $client->GetItemInInventory($slot);
        $mask |= (1 << $slot) unless $item;
    }
    return $mask;
}

# Hand one suitable pooled item to the client.
# Returns: item_id (>0) on success, -1 = fully equipped, -2 = nothing suitable,
#          0 = error.
sub Philanthropist_ClaimGear {
    my ($client) = @_;
    return 0 unless $client;

    my $dbh = plugin::LoadMysql();
    return 0 unless $dbh;

    my $empty_mask = Philanthropist_EmptyEquipMask($client);
    return -1 if $empty_mask == 0;

    my $class_bits = $client->GetClassesBitmask();
    my $race_bit   = $client->GetRaceBitmask();
    my $level      = $client->GetLevel();

    my $sth = $dbh->prepare(
        "SELECT id, item_id, slots, races FROM philanthropist_item_pool "
        . "WHERE quantity > 0 AND reqlevel <= ? "
        . "AND (classes = 65535 OR (classes & ?) <> 0) "
        . "ORDER BY stat_value DESC, id ASC"
    );
    $sth->execute($level, $class_bits);

    my $pick;
    while (my $r = $sth->fetchrow_hashref()) {
        next unless (($r->{slots} || 0) & $empty_mask);
        next unless (($r->{races} || 65535) == 65535 || (($r->{races}) & $race_bit));
        $pick = $r;
        last;
    }
    $sth->finish();
    return -2 unless $pick;

    $client->SummonItem($pick->{item_id});

    my $upd = $dbh->prepare("UPDATE philanthropist_item_pool SET quantity = quantity - 1 WHERE id = ?");
    $upd->execute($pick->{id});
    $upd->finish();
    $dbh->do("DELETE FROM philanthropist_item_pool WHERE quantity <= 0");

    return $pick->{item_id};
}

# ============================================================
# Philanthropist_PickupGrants($client) — deliver pending plat to player
# Called from global_player.pl EVENT_TIMER (per-player, any zone)
# ============================================================
sub Philanthropist_PickupGrants {
    my ($client) = @_;
    return unless $client;

    my $char_id = $client->CharacterID();
    my $dbh = plugin::LoadMysql();
    return unless $dbh;

    my $sth = $dbh->prepare(
        "SELECT id, amount, donor_names FROM pending_plat_grants "
        . "WHERE character_id = ? AND status = 'pending' ORDER BY id ASC LIMIT $PICKUP_LIMIT"
    );
    $sth->execute($char_id);

    while (my $row = $sth->fetchrow_hashref()) {
        $client->AddMoneyToPP(0, 0, 0, $row->{amount}, 1);
        $client->Message(15, "The generosity of Norrath's champions has blessed you with "
            . $row->{amount} . " platinum to aid your journey!");

        my $upd = $dbh->prepare(
            "UPDATE pending_plat_grants SET status = 'claimed', claimed_at = NOW() WHERE id = ?"
        );
        $upd->execute($row->{id});
        $upd->finish();
    }
    $sth->finish();
}

# ============================================================
# GM TOOLS
# ============================================================

# Philanthropist_ShowEligible($client) — list eligible recipients for GM
sub Philanthropist_ShowEligible {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    my $sth = $dbh->prepare(
        "SELECT cd.id AS character_id, cd.name, cd.level, cd.class, cd.time_played, cd.zone_id, cd.account_id "
        . "FROM character_data cd "
        . "INNER JOIN ("
        . "  SELECT account_id, MIN(id) AS pick_id"
        . "  FROM character_data"
        . "  WHERE level < $RECIP_MAX_LVL"
        . "  AND time_played < $RECIP_MAX_PLAY"
        . "  AND last_login > (UNIX_TIMESTAMP() - $ONLINE_WINDOW)"
        . "  AND zone_id NOT IN (" . join(",", @EXCLUDED_ZONES) . ")"
        . "  AND deleted_at IS NULL"
        . "  GROUP BY account_id"
        . ") sub ON cd.id = sub.pick_id"
        . " ORDER BY cd.level ASC, cd.time_played ASC"
    );
    $sth->execute();

    my @class_names = qw(UNK WAR CLR PAL RNG SHD DRU MNK BRD ROG SHM NEC WIZ MAG ENC BST BER);
    my $count = 0;

    $client->Message(14, "[GM] === Eligible Philanthropist Recipients ===");
    while (my $r = $sth->fetchrow_hashref()) {
        my $cls = $class_names[$r->{class}] || "?";
        my $played_min = int($r->{time_played});

        # Check daily cap
        my ($received) = $dbh->selectrow_array(
            "SELECT COALESCE(SUM(amount), 0) FROM pending_plat_grants "
            . "WHERE character_id = ? AND DATE(created_at) = CURDATE()",
            undef, $r->{character_id}
        );
        my $remaining = $DAILY_CAP_PP - $received;
        my $cap_str = $remaining <= 0 ? " [CAPPED]" : " (${remaining}pp remaining today)";

        $client->Message(14, "  $r->{name} - Lv$r->{level} $cls - ${played_min}m played - zone $r->{zone_id} - acct $r->{account_id}$cap_str");
        $count++;
    }
    $sth->finish();

    if ($count == 0) {
        $client->Message(14, "  (none)");
    }
    $client->Message(14, "[GM] Total eligible: $count");
}

# Philanthropist_ForceDistribute($client) — force immediate distribution (ignores pool threshold)
sub Philanthropist_ForceDistribute {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    my ($pool_total) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0) FROM philanthropist_pool WHERE distributed = 0"
    );

    if ($pool_total <= 0) {
        $client->Message(13, "[GM] Pool is empty. Nothing to distribute.");
        return;
    }

    $client->Message(14, "[GM] Forcing distribution of ${pool_total}pp...");

    # Temporarily set threshold to 0 and run
    my $saved = $POOL_THRESHOLD;
    $POOL_THRESHOLD = 0;
    Philanthropist_RunDistribution();
    $POOL_THRESHOLD = $saved;

    $client->Message(14, "[GM] Distribution complete.");
}

# Philanthropist_PoolStatus($client) — show pool total, donor breakdown, pending grants
sub Philanthropist_PoolStatus {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    # Pool summary
    my ($pool_total) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0) FROM philanthropist_pool WHERE distributed = 0"
    );
    my ($pool_count) = $dbh->selectrow_array(
        "SELECT COUNT(*) FROM philanthropist_pool WHERE distributed = 0"
    );

    $client->Message(14, "[GM] === Philanthropist Pool Status ===");
    $client->Message(14, "  Pool: ${pool_total}pp from $pool_count deposit(s)  (threshold: ${POOL_THRESHOLD}pp)");

    # Donor breakdown
    my $ds = $dbh->prepare(
        "SELECT donor_name, SUM(amount) AS total FROM philanthropist_pool WHERE distributed = 0 GROUP BY donor_name ORDER BY total DESC"
    );
    $ds->execute();
    while (my $r = $ds->fetchrow_hashref()) {
        $client->Message(14, "    $r->{donor_name}: $r->{total}pp");
    }
    $ds->finish();

    # Pending unclaimed grants
    my ($pending_count, $pending_total) = $dbh->selectrow_array(
        "SELECT COUNT(*), COALESCE(SUM(amount), 0) FROM pending_plat_grants WHERE status = 'pending'"
    );
    $client->Message(14, "  Pending grants: $pending_count totaling ${pending_total}pp unclaimed");

    # Lifetime stats
    my ($lifetime_distributed) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0) FROM philanthropist_pool WHERE distributed = 1"
    );
    my ($lifetime_claimed) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0) FROM pending_plat_grants WHERE status = 'claimed'"
    );
    $client->Message(14, "  Lifetime: ${lifetime_distributed}pp distributed, ${lifetime_claimed}pp claimed");
}

# Philanthropist_ClearPool($client) — wipe undistributed pool (GM only)
sub Philanthropist_ClearPool {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    my ($pool_total, $pool_count) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(amount), 0), COUNT(*) FROM philanthropist_pool WHERE distributed = 0"
    );

    if ($pool_count == 0) {
        $client->Message(14, "[GM] Pool is already empty.");
        return;
    }

    $dbh->do("DELETE FROM philanthropist_pool WHERE distributed = 0");
    $client->Message(14, "[GM] Cleared ${pool_total}pp from $pool_count deposit(s). Pool is now empty.");
}

# Philanthropist_ItemPoolStatus($client) — show adventurer gear pool (GM only)
sub Philanthropist_ItemPoolStatus {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    my ($rows, $pieces) = $dbh->selectrow_array(
        "SELECT COUNT(*), COALESCE(SUM(quantity), 0) FROM philanthropist_item_pool"
    );

    $client->Message(14, "[GM] === Adventurer Gear Pool ===");
    $client->Message(14, "  $pieces piece(s) across $rows stack(s)");

    my $sth = $dbh->prepare(
        "SELECT item_id, quantity, reqlevel, donor_name, created_at "
        . "FROM philanthropist_item_pool ORDER BY created_at ASC LIMIT 50"
    );
    $sth->execute();
    while (my $r = $sth->fetchrow_hashref()) {
        my $name = quest::getitemname($r->{item_id}) || "item $r->{item_id}";
        $client->Message(14, "    ${name} x$r->{quantity} (req $r->{reqlevel}) from $r->{donor_name} on $r->{created_at}");
    }
    $sth->finish();
}

# Philanthropist_ClearItemPool($client) — wipe adventurer gear pool (GM only)
sub Philanthropist_ClearItemPool {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message(13, "[GM] DB connection failed.");
        return;
    }

    my ($pieces) = $dbh->selectrow_array(
        "SELECT COALESCE(SUM(quantity), 0) FROM philanthropist_item_pool"
    );
    if (!$pieces) {
        $client->Message(14, "[GM] Gear pool is already empty.");
        return;
    }

    $dbh->do("DELETE FROM philanthropist_item_pool");
    $client->Message(14, "[GM] Cleared $pieces piece(s) from the gear pool.");
}

1;
