# ============================================================
# Ascendant Training System - Plugin
# Handles illegible tome turn-in, tiered credits, AA browsing,
# prerequisite checking, and AA rank purchasing.
#
# All public functions take $trainer_class (1-16) so each guild
# master only teaches their class's AAs and accepts their tomes.
# ============================================================

# ── Server progression constant ──
# Update this when a new expansion unlocks on the server.
# Expansion numbers: 0-9=Classic, 10-11=Kunark, 12-14=Velious, 15=Luclin, 16=PoP, 17+=GoD+
my $CURRENT_MAX_EXPANSION = 16;  # Currently: PoP

# ── Economy constants ──
# Each tome gives 1 credit of its tier; each AA rank costs 1 credit of its tier
my %TIER_PLAT_COST = (1 => 100,  2 => 300,  3 => 500);
my %TIER_NAMES     = (1 => 'Greater', 2 => 'Exalted', 3 => 'Ascendant');
my %TIER_COLORS    = (1 => '#00FF00', 2 => '#00CCFF', 3 => '#CC66FF');
my %TIER_BUCKET    = (1 => 'greater_credits', 2 => 'exalted_credits', 3 => 'ascendant_credits');

# ── $client->Message() color IDs (emote colors) ──
# IMPORTANT: Use IDs 0-19 only — higher IDs route to different chat windows
my $COLOR_HEADING = 18;   # cyan (headings, links, nav)
my $COLOR_GOLD    = 15;   # yellow (currency amounts)
my $COLOR_GREEN   = 14;   # light green (success/ready/buy)
my $COLOR_RED     = 13;   # red (errors)
my $COLOR_GRAY    = 12;   # light silver (muted/maxed)
my $COLOR_WHITE   = 0;    # white (default text)
my $COLOR_TEAL    = 5;    # light purple (tier accent)

# ── Class names for display ──
my %CLASS_NAMES = (
    1  => 'Warrior',     2  => 'Cleric',      3  => 'Paladin',
    4  => 'Ranger',      5  => 'Shadow Knight',6  => 'Druid',
    7  => 'Monk',        8  => 'Bard',        9  => 'Rogue',
    10 => 'Shaman',      11 => 'Necromancer', 12 => 'Wizard',
    13 => 'Magician',    14 => 'Enchanter',   15 => 'Beastlord',
    16 => 'Berserker',
);

# ── Illegible tome ID ranges (121571-121618, 3 per class × 16 classes) ──
# Formula: base = 121571 + (class - 1) * 3; T1=base, T2=base+1, T3=base+2
sub _get_tome_info {
    my ($item_id) = @_;
    return (0, 0) unless ($item_id >= 121571 && $item_id <= 121618);
    my $index = $item_id - 121571;
    my $tome_class = int($index / 3) + 1;   # 1-16
    my $tome_tier  = ($index % 3) + 1;      # 1-3
    return ($tome_class, $tome_tier);
}

# Items per page for AA browser popup
my $ITEMS_PER_PAGE = 10;

# ── Convert trainer class (1-16) to bitmask ──
sub _class_bitmask {
    my ($class_num) = @_;
    return 1 << ($class_num - 1);
}

# ── NMS multiclass: player's full class bitmask (all of their classes) ──
# NMS grants a player up to 3 classes via GetClassesBitmask(). Using only the
# primary class here would misclassify secondary classes as "cross-class" and
# grant duplicate universal AAs on top of native ones.
sub _get_player_bitmask {
    my ($client) = @_;
    return 0 unless $client;
    my $bm = $client->GetClassesBitmask();
    return $bm if $bm;
    my $pc = $client->GetClass();
    return ($pc >= 1 && $pc <= 16) ? (1 << ($pc - 1)) : 0;
}

# ── NMS multiclass: is the player ALREADY the trainer's class? ──
# Native AAs for a player's own classes are granted through experience on NMS
# (GrantClassesAA), so credit purchases of those AAs would be redundant/wasteful.
sub _is_native_class {
    my ($client, $trainer_class) = @_;
    return 0 unless $client;
    my $player_bitmask = _get_player_bitmask($client);
    return 0 unless $player_bitmask;
    return ($player_bitmask & _class_bitmask($trainer_class)) ? 1 : 0;
}

# Mapping scope decides which trainer may offer an AA. Native grant eligibility
# must come from the real original AA row, or bad mapping masks can make the
# plugin grant an original AA to a class the core server rejects.
sub _has_native_access {
    my ($aa, $player_bitmask) = @_;
    my $actual_classes = $aa->{original_ability_classes};
    $actual_classes = $aa->{original_classes} unless defined $actual_classes;
    return (($actual_classes & $player_bitmask) > 0) ? 1 : 0;
}

# ============================================================
# GetCreditBalance - Read credit balance for a specific tier + class
# Key: character-{charid}-{tier}_credits_{class}
# ============================================================
sub GetCreditBalance {
    my ($client, $tier, $trainer_class) = @_;
    my $char_id = $client->CharacterID();
    my $suffix = $TIER_BUCKET{$tier} || return 0;
    my $val = quest::get_data("character-${char_id}-${suffix}_${trainer_class}");
    return int($val || 0);
}

# ============================================================
# _set_credit_balance - Write credit balance for a specific tier + class
# ============================================================
sub _set_credit_balance {
    my ($client, $tier, $trainer_class, $amount) = @_;
    $amount = int($amount);
    $amount = 0 if $amount < 0;
    my $char_id = $client->CharacterID();
    my $suffix = $TIER_BUCKET{$tier} || return;
    quest::set_data("character-${char_id}-${suffix}_${trainer_class}", $amount);
}

# ============================================================
# GetAllBalances - Return hash of all 3 credit balances for a class
# ============================================================
sub GetAllBalances {
    my ($client, $trainer_class) = @_;
    return (
        1 => GetCreditBalance($client, 1, $trainer_class),
        2 => GetCreditBalance($client, 2, $trainer_class),
        3 => GetCreditBalance($client, 3, $trainer_class),
    );
}

# ============================================================
# HandleTomeTurnin - Accept illegible tome stacks + plat, award credits
# Only accepts tomes matching $trainer_class.
# Processes stacks using while loop pattern.
# Returns: 1 if any tomes consumed, 0 otherwise
# ============================================================
sub HandleTomeTurnin {
    my ($npc, $client, $itemcount_ref, $trainer_class, $plat_given, $gold_given, $silver_given, $copper_given) = @_;

    # Block Tomeless players
    if (quest::get_data("tomeless_" . $client->CharacterID())) {
        $client->Message($COLOR_RED, "You have forsaken the path of tomes. The Tomeless do not seek this knowledge.");
        return 0;
    }

    my $trainer_name = $CLASS_NAMES{$trainer_class} || "Unknown";

    $plat_given   = int($plat_given   || 0);
    $gold_given   = int($gold_given   || 0);
    $silver_given = int($silver_given || 0);
    $copper_given = int($copper_given || 0);

    # Find the first tome in the handin
    foreach my $item_id (keys %{$itemcount_ref}) {
        next unless $item_id;
        my ($tome_class, $tier) = _get_tome_info($item_id);
        next unless $tier;

        # Reject tomes for a different class
        if ($tome_class != $trainer_class) {
            my $tome_class_name = $CLASS_NAMES{$tome_class} || "Unknown";
            $client->Message($COLOR_RED, "This is a $tome_class_name tome. I only accept $trainer_name tomes. Seek the $tome_class_name guild master instead.");
            return 0;
        }

        my $count = int($itemcount_ref->{$item_id} || 1);
        $count = 1 if $count < 1;
        my $cost_pp  = $TIER_PLAT_COST{$tier};
        my $total_cost_pp = $cost_pp * $count;
        my $tier_name = $TIER_NAMES{$tier};

        # NMS holds trade platinum separately from carried money, so payment must come
        # from the money handed in the trade window - and it must be exact.
        if ($plat_given != $total_cost_pp || $gold_given != 0 || $silver_given != 0 || $copper_given != 0) {
            $client->Message($COLOR_RED, "Deciphering $count $tier_name $trainer_name tome" . ($count > 1 ? "s" : "") . " requires exactly $total_cost_pp platinum.");
            return 0;
        }

        # Consume the tomes and the exact platinum via the native handin system
        if (quest::handin({$item_id => $count, "platinum" => $total_cost_pp})) {
            my $current = GetCreditBalance($client, $tier, $trainer_class);
            _set_credit_balance($client, $tier, $trainer_class, $current + $count);

            quest::ding();
            my $plural = $count > 1 ? "s" : "";
            my $new_balance = GetCreditBalance($client, $tier, $trainer_class);
            $client->Message($COLOR_GREEN, "I have deciphered $count tome$plural for $total_cost_pp platinum. You received $count $tier_name $trainer_name Credit$plural. (Total: $new_balance)");
            quest::debug("InsightTrainer: $trainer_name $tier_name tome turn-in x$count, cost=${total_cost_pp}pp, new balance=$new_balance");
            return 1;
        }

        return 0;
    }

    return 0;
}

# ============================================================
# ShowAllAACredits - Display all credits across all class trainers
# Used by /myaacredits player command
# ============================================================
sub ShowAllAACredits {
    my ($client) = @_;

    my $popup = "<c \"#FFD700\">Your AA Training Credits</c><br><br>";
    
    # Loop through all 16 classes and show all, even with 0 credits
    for my $class_id (1..16) {
        my $class_name = $CLASS_NAMES{$class_id};
        my %bal = GetAllBalances($client, $class_id);
        
        $popup .= "<c \"#FFFFFF\">$class_name:</c> ";
        $popup .= "<c \"#00FF00\">G:$bal{1}</c> ";
        $popup .= "<c \"#00CCFF\">E:$bal{2}</c> ";
        $popup .= "<c \"#CC66FF\">A:$bal{3}</c><br>";
    }
    
    $popup .= "<br><c \"#AAAAAA\">Visit guild masters to browse and purchase abilities.</c>";
    quest::popup("AA Training Credits", $popup, 0, 0, 0);
}

sub GetUniqueAACount {
    my ($client) = @_;
    return 0 unless $client;

    my $char_id = $client->CharacterID();
    my $dbh = plugin::LoadMysql();
    return 0 unless $dbh;

    my $count = 0;
    my $sth = $dbh->prepare(
        "SELECT COUNT(DISTINCT aa_id) FROM character_alternate_abilities WHERE id = ?"
    );

    if ($sth && $sth->execute($char_id)) {
        ($count) = $sth->fetchrow_array();
        $sth->finish();
    }

    $dbh->disconnect();
    return int($count || 0);
}

# ============================================================
# ShowBalance - Display current credit balances
# ============================================================
sub ShowBalance {
    my ($client, $trainer_class) = @_;
    my %bal = GetAllBalances($client, $trainer_class);
    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";

    my $popup = "<c \"#FFD700\">$class_name Training - Credits</c><br><br>";
    $popup .= "<c \"#AAAAAA\">Your Credits:</c><br>";
    $popup .= "  <c \"#00FF00\">Greater Credits:</c> <c \"#FFFFFF\">$bal{1}</c><br>";
    $popup .= "  <c \"#00CCFF\">Exalted Credits:</c> <c \"#FFFFFF\">$bal{2}</c><br>";
    $popup .= "  <c \"#CC66FF\">Ascendant Credits:</c> <c \"#FFFFFF\">$bal{3}</c><br><br>";
    $popup .= "<c \"#AAAAAA\">Earn credits by turning in $class_name illegible tomes:</c><br>";
    $popup .= "- <c \"#00FF00\">Greater Tome</c> + 100pp = 1 Greater Credit<br>";
    $popup .= "- <c \"#00CCFF\">Exalted Tome</c> + 300pp = 1 Exalted Credit<br>";
    $popup .= "- <c \"#CC66FF\">Ascendant Tome</c> + 500pp = 1 Ascendant Credit<br><br>";
    $popup .= "<c \"#AAAAAA\">Each credit buys one rank of its tier:</c><br>";
    $popup .= "- 1 <c \"#00FF00\">Greater Credit</c> = 1 Greater AA rank<br>";
    $popup .= "- 1 <c \"#00CCFF\">Exalted Credit</c> = 1 Exalted AA rank<br>";
    $popup .= "- 1 <c \"#CC66FF\">Ascendant Credit</c> = 1 Ascendant AA rank";
    quest::popup("$class_name Training", $popup, 0, 0, 0);
    $client->Message($COLOR_HEADING, quest::saylink("train", 1, "[Browse $class_name Abilities]") . "  " . quest::saylink("balance", 1, "[Refresh Balance]"));
}

# ============================================================
# ShowTrainingMenu - Paginated AA browser popup
# Only shows AAs whose original_classes includes $trainer_class.
# ============================================================
sub ShowTrainingMenu {
    my ($client, $page, $filter, $trainer_class) = @_;
    $page = 0 unless defined $page;
    $filter = '' unless defined $filter;

    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message($COLOR_RED, "The training records are unavailable. Please try again later.");
        return;
    }

    my %bal = GetAllBalances($client, $trainer_class);
    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";
    my $class_bitmask = _class_bitmask($trainer_class);
    my $native_class = _is_native_class($client, $trainer_class);

    # Fetch AAs for this class from mapping
    my @where = (
        "(acm.original_classes & $class_bitmask) > 0",
        "oa.enabled = 1",
        "ua.enabled = 1",
    );
    my @params;
    if ($filter =~ /^[123]$/) {
        push @where, "acm.tier = ?";
        push @params, int($filter);
    }
    my $where_clause = "WHERE " . join(" AND ", @where);

    # Also filter to current expansion only
    push @where, "ur.expansion <= ?";
    push @params, $CURRENT_MAX_EXPANSION;

    $where_clause = "WHERE " . join(" AND ", @where);

    my $sth = $dbh->prepare(
        "SELECT acm.universal_aa_id, acm.aa_name, acm.tier, acm.original_classes, " .
        "ua.first_rank_id AS universal_first_rank_id, " .
        "oa.first_rank_id AS original_first_rank_id, " .
        "oa.classes AS original_ability_classes " .
        "FROM aa_custom_mapping acm " .
        "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
        "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
        "JOIN aa_ranks ur ON ur.id = ua.first_rank_id " .
        "$where_clause " .
        "ORDER BY acm.tier, acm.aa_name"
    );
    $sth->execute(@params);

    my @all_aas;
    while (my $row = $sth->fetchrow_hashref()) {
        push @all_aas, $row;
    }
    $sth->finish();

    my $total = scalar @all_aas;
    my $total_pages = int(($total + $ITEMS_PER_PAGE - 1) / $ITEMS_PER_PAGE);
    $page = 0 if $page < 0;
    $page = $total_pages - 1 if $page >= $total_pages && $total_pages > 0;

    my $start = $page * $ITEMS_PER_PAGE;
    my $end = $start + $ITEMS_PER_PAGE - 1;
    $end = $total - 1 if $end >= $total;

    # Header with all 3 balances
    $client->Message($COLOR_HEADING, "--- $class_name AA Training --- G:$bal{1} E:$bal{2} A:$bal{3} --- (" . ($start + 1) . "-" . ($end + 1) . " of $total, page " . ($page + 1) . "/$total_pages) ---");

    # Get player class for native access check
    my $player_bitmask = _get_player_bitmask($client);

    # Only hide AAs where the next rank requires level > 60.
    # Maxed AAs and prereq-blocked AAs always remain visible.
    @all_aas = grep {
        my $frid = _has_native_access($_, $player_bitmask)
                   ? $_->{original_first_rank_id}
                   : $_->{universal_first_rank_id};
        my $cur          = $client->GetAALevel($frid);
        my $next_rank_id = _get_nth_rank_id($dbh, $frid, $cur);
        if (!$next_rank_id) {
            1;  # maxed — always show
        } else {
            my ($req) = $dbh->selectrow_array(
                "SELECT level_req FROM aa_ranks WHERE id = ?", undef, $next_rank_id
            );
            !$req || $req == 0 || $req <= 60;  # hide only if level_req > 60
        }
    } @all_aas;

    # Recompute totals after filter
    $total = scalar @all_aas;
    $total_pages = int(($total + $ITEMS_PER_PAGE - 1) / $ITEMS_PER_PAGE);
    $page = 0 if $page < 0;
    $page = $total_pages - 1 if $page >= $total_pages && $total_pages > 0;
    $start = $page * $ITEMS_PER_PAGE;
    $end = $start + $ITEMS_PER_PAGE - 1;
    $end = $total - 1 if $end >= $total;

    for (my $i = $start; $i <= $end; $i++) {
        my $aa = $all_aas[$i];
        my $uid = $aa->{universal_aa_id};
        my $name = $aa->{aa_name};
        my $tier = $aa->{tier};
        my $tier_name = $TIER_NAMES{$tier};
        my $tier_balance = $bal{$tier} || 0;

        # Check if player has native access to determine which first_rank_id to use
        my $has_native = _has_native_access($aa, $player_bitmask);
        my $first_rank_id = $has_native ? $aa->{original_first_rank_id} : $aa->{universal_first_rank_id};

        my $current_rank = $client->GetAALevel($first_rank_id);
        my $max_rank = _count_ranks($dbh, $first_rank_id);

        if ($current_rank >= $max_rank) {
            $client->Message($COLOR_GRAY,
                "($tier_name) " . quest::saylink("aainfo $uid", 1, $name) . " $current_rank/$max_rank (MAXED)");
        } else {
            my $can_buy = _check_can_buy($dbh, $client, $first_rank_id, $current_rank, $tier_balance, 1);

            my $line = "($tier_name) " . quest::saylink("aainfo $uid", 1, $name) . " $current_rank/$max_rank";
            if ($native_class) {
                $line .= " (native)";
            } elsif ($can_buy) {
                $line .= " " . quest::saylink("buyaa $uid", 1, "[Buy]");
            }
            $client->Message($COLOR_HEADING, $line);
        }
    }

    # Pagination (silent saylinks)
    my $filter_key = $filter eq '' ? 'all' : "t$filter";
    my $nav = "";
    if ($page > 0) {
        my $prev = $page - 1;
        $nav .= quest::saylink("train $filter_key $prev", 1, "<< Prev") . '  ';
    }
    if ($page < $total_pages - 1) {
        my $nxt = $page + 1;
        $nav .= quest::saylink("train $filter_key $nxt", 1, "Next >>") . '  ';
    }
    $client->Message($COLOR_HEADING, $nav) if $nav;

    $dbh->disconnect();
}

# ============================================================
# ShowAADetail - Detail popup for a single AA
# Validates the AA belongs to $trainer_class before showing.
# ============================================================
sub ShowAADetail {
    my ($client, $universal_aa_id, $trainer_class) = @_;

    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message($COLOR_RED, "The training records are unavailable.");
        return;
    }

    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";
    my $class_bitmask = _class_bitmask($trainer_class);

    # Get mapping info
    my $sth = $dbh->prepare(
        "SELECT acm.universal_aa_id, acm.original_aa_id, acm.aa_name, acm.tier, acm.original_classes, " .
        "ua.first_rank_id AS universal_first_rank_id, " .
        "oa.first_rank_id AS original_first_rank_id, " .
        "oa.classes AS original_ability_classes " .
        "FROM aa_custom_mapping acm " .
        "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
        "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
        "WHERE acm.universal_aa_id = ? " .
        "AND oa.enabled = 1 " .
        "AND ua.enabled = 1"
    );
    $sth->execute($universal_aa_id);
    my $aa = $sth->fetchrow_hashref();
    $sth->finish();

    unless ($aa) {
        $client->Message($COLOR_RED, "I cannot find that ability in my records.");
        $dbh->disconnect();
        return;
    }

    # Validate this AA belongs to this trainer's class
    unless (($aa->{original_classes} & $class_bitmask) > 0) {
        $client->Message($COLOR_RED, "That ability is not part of the $class_name discipline. Seek the appropriate guild master.");
        $dbh->disconnect();
        return;
    }

    my $tier = $aa->{tier};
    my $tier_name = $TIER_NAMES{$tier};
    my $tier_color = $TIER_COLORS{$tier};
    my $tier_balance = GetCreditBalance($client, $tier, $trainer_class);

    # Native class players use original rank chain; cross-class use universal
    my $player_bitmask = _get_player_bitmask($client);
    my $has_native = _has_native_access($aa, $player_bitmask);
    my $first_rank_id = $has_native ? $aa->{original_first_rank_id} : $aa->{universal_first_rank_id};

    my $current_rank = $client->GetAALevel($first_rank_id);
    my $max_rank = _count_ranks($dbh, $first_rank_id);

    # Get description from dbstrings
    my ($desc_sid) = $dbh->selectrow_array(
        "SELECT desc_sid FROM aa_ranks WHERE id = ?", undef, $first_rank_id
    );
    my $description = "";
    if ($desc_sid && $desc_sid > 0) {
        ($description) = $dbh->selectrow_array(
            "SELECT value FROM db_str WHERE id = ? AND type = 4", undef, $desc_sid
        );
    }

    # Get effects from first rank
    my $eff_sth = $dbh->prepare(
        "SELECT effect_id, base1, base2 FROM aa_rank_effects WHERE rank_id = ? ORDER BY slot"
    );
    $eff_sth->execute($first_rank_id);

    my @effects;
    while (my ($eid, $b1, $b2) = $eff_sth->fetchrow_array()) {
        push @effects, { id => $eid, base1 => $b1, base2 => $b2 };
    }
    $eff_sth->finish();

    # Get level requirement for next rank
    my $next_rank_id = _get_nth_rank_id($dbh, $first_rank_id, $current_rank);
    my $level_req = 0;
    if ($next_rank_id) {
        ($level_req) = $dbh->selectrow_array(
            "SELECT level_req FROM aa_ranks WHERE id = ?", undef, $next_rank_id
        );
    }

    # Check prerequisites
    my @prereqs;
    if ($next_rank_id) {
        my $pre_sth = $dbh->prepare(
            "SELECT rp.aa_id, rp.points, aa.name as aa_name " .
            "FROM aa_rank_prereqs rp " .
            "LEFT JOIN aa_ability aa ON aa.id = rp.aa_id " .
            "WHERE rp.rank_id = ?"
        );
        $pre_sth->execute($next_rank_id);
        while (my $p = $pre_sth->fetchrow_hashref()) {
            my $prereq_aa = $p->{aa_id};
            my $prereq_name = $p->{aa_name} || "AA $prereq_aa";
            my $prereq_points = $p->{points};

            # Check the direct prereq and its mapped counterpart in either direction.
            my ($prereq_first_rank_direct) = $dbh->selectrow_array(
                "SELECT first_rank_id FROM aa_ability WHERE id = ?", undef, $prereq_aa
            );
            my ($prereq_first_rank_alt) = $dbh->selectrow_array(
                "SELECT CASE WHEN acm.original_aa_id = ? THEN ua.first_rank_id ELSE oa.first_rank_id END " .
                "FROM aa_custom_mapping acm " .
                "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
                "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
                "WHERE (acm.original_aa_id = ? OR acm.universal_aa_id = ?) " .
                "AND oa.enabled = 1 " .
                "AND ua.enabled = 1 " .
                "LIMIT 1", undef, $prereq_aa, $prereq_aa, $prereq_aa
            );
            my $rank_direct = $prereq_first_rank_direct ? $client->GetAALevel($prereq_first_rank_direct) : 0;
            my $rank_alt = $prereq_first_rank_alt ? $client->GetAALevel($prereq_first_rank_alt) : 0;
            my $player_prereq_rank = ($rank_direct > $rank_alt) ? $rank_direct : $rank_alt;
            my $met = $player_prereq_rank >= $prereq_points ? 1 : 0;

            push @prereqs, {
                name => $prereq_name,
                required => $prereq_points,
                current => $player_prereq_rank,
                met => $met
            };
        }
        $pre_sth->finish();
    }

    # Static detail popup with <c> color tags
    my $popup = "<c \"$tier_color\">$aa->{aa_name}</c> <c \"#888888\">[$tier_name - $class_name]</c><br><br>";

    if ($description) {
        $popup .= "<c \"#CCCCCC\">$description</c><br><br>";
    }

    $popup .= "Rank: <c \"#FFFFFF\">$current_rank / $max_rank</c><br>";
    $popup .= "Cost: <c \"#FFD700\">1 $tier_name Credit per rank</c><br>";

    my $total_remaining = $max_rank - $current_rank;
    $popup .= "Remaining to Max: <c \"#FFD700\">$total_remaining $tier_name Credit" . ($total_remaining != 1 ? "s" : "") . "</c><br>";
    $popup .= "Your $tier_name Credits: <c \"#00FF00\">$tier_balance</c><br>";

    if ($level_req && $level_req > 0) {
        my $player_level = $client->GetLevel();
        my $level_color = $player_level >= $level_req ? "#00FF00" : "#FF4444";
        $popup .= "Level Required: <c \"$level_color\">$level_req</c> (You: $player_level)<br>";
    }

    $popup .= "<br>";

    # Effects
    if (@effects) {
        $popup .= "<c \"#00CCFF\">Effects:</c><br>";
        foreach my $eff (@effects) {
            $popup .= "  Effect $eff->{id}: base $eff->{base1}<br>";
        }
        $popup .= "<br>";
    }

    # Prerequisites
    if (@prereqs) {
        $popup .= "<c \"#FFA500\">Prerequisites:</c><br>";
        foreach my $p (@prereqs) {
            my $color = $p->{met} ? "#00FF00" : "#FF4444";
            my $check = $p->{met} ? "MET" : "NOT MET";
            $popup .= "  <c \"$color\">[$check]</c> $p->{name}: $p->{current}/$p->{required} ranks<br>";
        }
        $popup .= "<br>";
    }

    # Determine purchase status
    my $can_buy = 1;
    my $reason = "";

    if ($current_rank >= $max_rank) {
        $can_buy = 0;
        $reason = "Mastered";
    } else {
        if ($tier_balance < 1) {
            $can_buy = 0;
            $reason = "No $tier_name Credits ($tier_balance)";
        }
        if ($level_req && $level_req > 0 && $client->GetLevel() < $level_req) {
            $can_buy = 0;
            $reason = "Level too low (need $level_req)";
        }
        foreach my $p (@prereqs) {
            unless ($p->{met}) {
                $can_buy = 0;
                $reason = "Missing prerequisite: $p->{name}";
                last;
            }
        }
    }

    # Status in popup
    if ($current_rank >= $max_rank) {
        $popup .= "<c \"#888888\">You have mastered this ability.</c><br>";
    } elsif ($can_buy) {
        $popup .= "<c \"#00FF00\">Ready to purchase rank " . ($current_rank + 1) . "</c><br>";
    } else {
        $popup .= "<c \"#FF4444\">Cannot purchase: $reason</c><br>";
    }

    quest::popup("$aa->{aa_name} - $class_name", $popup, 0, 0, 0);

    $dbh->disconnect();
}

# ============================================================
# ShowBuyConfirmation - Yes/No popup to confirm AA purchase
# popup_id = universal_aa_id (used in EVENT_POPUPRESPONSE)
# ============================================================
sub ShowBuyConfirmation {
    my ($client, $universal_aa_id, $trainer_class) = @_;

    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message($COLOR_RED, "The training records are unavailable.");
        return;
    }

    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";
    my $class_bitmask = _class_bitmask($trainer_class);

    my $sth = $dbh->prepare(
        "SELECT acm.universal_aa_id, acm.aa_name, acm.tier, acm.original_classes, " .
        "ua.first_rank_id AS universal_first_rank_id, " .
        "oa.first_rank_id AS original_first_rank_id, " .
        "oa.classes AS original_ability_classes " .
        "FROM aa_custom_mapping acm " .
        "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
        "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
        "WHERE acm.universal_aa_id = ? " .
        "AND oa.enabled = 1 " .
        "AND ua.enabled = 1"
    );
    $sth->execute($universal_aa_id);
    my $aa = $sth->fetchrow_hashref();
    $sth->finish();

    unless ($aa && ($aa->{original_classes} & $class_bitmask) > 0) {
        $client->Message($COLOR_RED, "That ability is not available.");
        $dbh->disconnect();
        return;
    }

    # NMS multiclass: block credit purchases of the player's own classes' AAs
    if (_is_native_class($client, $trainer_class)) {
        $client->Message($COLOR_RED, "You are already a $class_name. Native abilities are earned through experience - seek the guild masters of classes you do not yet know.");
        $dbh->disconnect();
        return;
    }

    my $tier = $aa->{tier};
    my $tier_name = $TIER_NAMES{$tier};
    my $tier_balance = GetCreditBalance($client, $tier, $trainer_class);

    # Native class players use original rank chain; cross-class use universal
    my $player_bitmask = _get_player_bitmask($client);
    my $has_native = _has_native_access($aa, $player_bitmask);
    my $first_rank_id = $has_native ? $aa->{original_first_rank_id} : $aa->{universal_first_rank_id};

    my $current_rank = $client->GetAALevel($first_rank_id);
    my $max_rank = _count_ranks($dbh, $first_rank_id);

    if ($current_rank >= $max_rank) {
        $client->Message($COLOR_GRAY, "You have already mastered $aa->{aa_name}.");
        $dbh->disconnect();
        return;
    }

    my $can_buy = _check_can_buy($dbh, $client, $first_rank_id, $current_rank, $tier_balance, 1);
    unless ($can_buy) {
        $client->Message($COLOR_RED, "You cannot purchase $aa->{aa_name} right now. Check your credits, level, and prerequisites.");
        $dbh->disconnect();
        return;
    }

    my $next_rank = $current_rank + 1;
    my $popup = "<c \"#FFD700\">Confirm Purchase</c><br><br>";
    $popup .= "Ability: <c \"#FFFFFF\">$aa->{aa_name}</c><br>";
    $popup .= "Tier: <c \"$TIER_COLORS{$tier}\">$tier_name</c><br>";
    $popup .= "Rank: <c \"#FFFFFF\">$current_rank -> $next_rank</c> of $max_rank<br><br>";
    $popup .= "Cost: <c \"#FFD700\">1 $tier_name Credit</c><br>";
    $popup .= "Your $tier_name Credits: <c \"#00FF00\">$tier_balance</c><br>";
    $popup .= "After Purchase: <c \"#00FF00\">" . ($tier_balance - 1) . "</c><br><br>";
    $popup .= "<c \"#AAAAAA\">Click Yes to confirm purchase.</c>";

    # popup_id = universal_aa_id, buttons = 1 (Yes/No)
    quest::popup("Confirm: $aa->{aa_name}", $popup, $universal_aa_id, 1, 0);

    $dbh->disconnect();
}

# ============================================================
# HandlePopupResponse - Process Yes click on buy confirmation
# Called from EVENT_POPUPRESPONSE in NPC script
# ============================================================
sub HandlePopupResponse {
    my ($client, $popup_id, $trainer_class) = @_;

    # popup_id is the universal_aa_id from ShowBuyConfirmation
    # Only process if it looks like a valid AA ID (> 0)
    return 0 unless $popup_id && $popup_id > 0;

    HandleTrainRequest($client, $popup_id, $trainer_class);
    return 1;
}

# ============================================================
# HandleTrainRequest - Validate and grant a single AA rank
# Validates the AA belongs to $trainer_class before granting.
# ============================================================
sub HandleTrainRequest {
    my ($client, $universal_aa_id, $trainer_class) = @_;

    # Block Tomeless players
    if (quest::get_data("tomeless_" . $client->CharacterID())) {
        $client->Message($COLOR_RED, "You walk the path of The Tomeless. Cross-class training is closed to you.");
        return 0;
    }

    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        $client->Message($COLOR_RED, "The training records are unavailable.");
        return 0;
    }

    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";
    my $class_bitmask = _class_bitmask($trainer_class);

    # Get mapping info
    my $sth = $dbh->prepare(
        "SELECT acm.universal_aa_id, acm.original_aa_id, acm.aa_name, acm.tier, acm.original_classes, " .
        "ua.first_rank_id AS universal_first_rank_id, " .
        "oa.first_rank_id AS original_first_rank_id, " .
        "oa.classes AS original_ability_classes " .
        "FROM aa_custom_mapping acm " .
        "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
        "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
        "WHERE acm.universal_aa_id = ? " .
        "AND oa.enabled = 1 " .
        "AND ua.enabled = 1"
    );
    $sth->execute($universal_aa_id);
    my $aa = $sth->fetchrow_hashref();
    $sth->finish();

    unless ($aa) {
        $client->Message($COLOR_RED, "I cannot find that ability.");
        $dbh->disconnect();
        return 0;
    }

    # Validate this AA belongs to this trainer's class
    unless (($aa->{original_classes} & $class_bitmask) > 0) {
        $client->Message($COLOR_RED, "That ability is not part of the $class_name discipline.");
        $dbh->disconnect();
        return 0;
    }

    # NMS multiclass: block credit purchases of the player's own classes' AAs
    if (_is_native_class($client, $trainer_class)) {
        $client->Message($COLOR_RED, "You are already a $class_name. Native abilities are earned through experience - seek the guild masters of classes you do not yet know.");
        $dbh->disconnect();
        return 0;
    }

    my $player_bitmask = _get_player_bitmask($client);
    my $has_native = _has_native_access($aa, $player_bitmask);

    my $tier = $aa->{tier};
    my $tier_name = $TIER_NAMES{$tier};
    my $tier_balance = GetCreditBalance($client, $tier, $trainer_class);
    my $aa_name = $aa->{aa_name};

    # Native class players get their original AA; cross-class players get universal
    my $aa_id_to_grant = $has_native ? $aa->{original_aa_id}    : $aa->{universal_aa_id};
    my $first_rank_id  = $has_native ? $aa->{original_first_rank_id} : $aa->{universal_first_rank_id};

    quest::debug("InsightTrainer: Buying $aa_name ($class_name) - " . ($has_native ? "native" : "cross-class") . ", grant_aa=$aa_id_to_grant, first_rank=$first_rank_id");

    # Check current rank
    my $current_rank = $client->GetAALevel($first_rank_id);
    my $max_rank = _count_ranks($dbh, $first_rank_id);

    if ($current_rank >= $max_rank) {
        $client->Message($COLOR_GRAY, "You have already mastered $aa_name.");
        $dbh->disconnect();
        return 0;
    }

    # Check credit balance
    if ($tier_balance < 1) {
        $client->Message($COLOR_RED, "You need 1 $tier_name Credit but have $tier_balance.");
        $dbh->disconnect();
        return 0;
    }

    # Get the next rank ID
    my $target_rank_number = $current_rank + 1;
    my $target_rank_id = _get_nth_rank_id($dbh, $first_rank_id, $current_rank);

    unless ($target_rank_id) {
        $client->Message($COLOR_RED, "An error occurred finding the next rank.");
        $dbh->disconnect();
        return 0;
    }

    # Check level requirement
    my $level_req = $dbh->selectrow_array(
        "SELECT level_req FROM aa_ranks WHERE id = ?", undef, $target_rank_id
    );
    $level_req = 0 unless defined $level_req;
    my $player_level = $client->GetLevel();
    quest::debug("InsightTrainer: Level check - player=$player_level, required=" . (defined $level_req ? $level_req : "NULL") . ", rank_id=$target_rank_id");
    if ($level_req > 0 && $player_level < $level_req) {
        $client->Message($COLOR_RED, "This rank requires level $level_req. You are level $player_level.");
        $dbh->disconnect();
        return 0;
    }

    # Check prerequisites, accepting explicit original/universal mapping pairs in either direction.
    my $pre_sth = $dbh->prepare(
        "SELECT rp.aa_id, rp.points, aa.name as aa_name, aa.first_rank_id " .
        "FROM aa_rank_prereqs rp " .
        "LEFT JOIN aa_ability aa ON aa.id = rp.aa_id " .
        "WHERE rp.rank_id = ?"
    );
    $pre_sth->execute($target_rank_id);
    while (my $p = $pre_sth->fetchrow_hashref()) {
        my $prereq_first_rank_direct = $p->{first_rank_id};
        my $prereq_name = $p->{aa_name} || "AA $p->{aa_id}";

        unless ($prereq_first_rank_direct) {
            quest::debug("InsightTrainer: WARNING - Prerequisite AA $p->{aa_id} not found in aa_ability table");
            next;
        }

        my ($prereq_first_rank_alt) = $dbh->selectrow_array(
            "SELECT CASE WHEN acm.original_aa_id = ? THEN ua.first_rank_id ELSE oa.first_rank_id END " .
            "FROM aa_custom_mapping acm " .
            "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
            "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
            "WHERE (acm.original_aa_id = ? OR acm.universal_aa_id = ?) " .
            "AND oa.enabled = 1 " .
            "AND ua.enabled = 1 " .
            "LIMIT 1", undef, $p->{aa_id}, $p->{aa_id}, $p->{aa_id}
        );

        my $rank_direct = $client->GetAALevel($prereq_first_rank_direct);
        my $rank_alt = $prereq_first_rank_alt ? $client->GetAALevel($prereq_first_rank_alt) : 0;
        my $player_prereq_rank = ($rank_direct > $rank_alt) ? $rank_direct : $rank_alt;

        quest::debug("InsightTrainer: Prereq check - $prereq_name (aa_id=$p->{aa_id}): need $p->{points}, have direct=$rank_direct alt=$rank_alt");

        if ($player_prereq_rank < $p->{points}) {
            $client->Message($COLOR_RED, "You need $p->{points} rank" . ($p->{points} > 1 ? "s" : "") . " of $prereq_name first (you have $player_prereq_rank).");
            $pre_sth->finish();
            $dbh->disconnect();
            return 0;
        }
    }
    $pre_sth->finish();

    # All checks passed — grant the rank
    # API: GrantAlternateAdvancementAbility(aa_id, total_points, ignore_cost)
    # Second parameter is TOTAL points, not increment
    my $new_total_points = $current_rank + 1;
    quest::debug("InsightTrainer: About to grant - aa_id=$aa_id_to_grant, total_points=$new_total_points (was $current_rank), first_rank_id=$first_rank_id");
    my $result = $client->GrantAlternateAdvancementAbility($aa_id_to_grant, $new_total_points, 1);
    quest::debug("InsightTrainer: GrantAA result=$result");

    if ($result) {
        # Deduct 1 credit of this tier
        my $new_balance = $tier_balance - 1;
        _set_credit_balance($client, $tier, $trainer_class, $new_balance);

        quest::ding();
        my $rank_msg = $max_rank > 1 ? " (Rank $target_rank_number/$max_rank)" : "";
        $client->Message($COLOR_GREEN, "You have learned $aa_name$rank_msg! [Cross-Class]");
        $client->Message($COLOR_HEADING, "1 $tier_name Credit spent. $tier_name Credits remaining: $new_balance  " . quest::saylink("train", 1, "[Continue Training]"));
        quest::debug("InsightTrainer: Granted $aa_name rank $target_rank_number ($class_name), -1 $tier_name credit, balance=$new_balance");
        $dbh->disconnect();
        return 1;
    } else {
        $client->Message($COLOR_RED, "Failed to grant this ability. You may not meet a hidden requirement.");
        quest::debug("InsightTrainer: GrantAA FAILED for $aa_name ($class_name)");
        $dbh->disconnect();
        return 0;
    }
}

# ============================================================
# HandleSay - Process all say commands from the NPC script
# $trainer_class: 1-16, determines which class this trainer teaches
# Returns 1 if handled, 0 if not
# ============================================================
sub HandleSay {
    my ($client, $text, $trainer_class) = @_;
    my $class_name = $CLASS_NAMES{$trainer_class} || "Unknown";

    # Block Tomeless players from training system
    if (quest::get_data("tomeless_" . $client->CharacterID())) {
        if ($text =~ /hail/i) {
            $client->Message($COLOR_RED, "You walk the path of The Tomeless. The training system is closed to you. Speak to Haliax Greycloak if you wish to renounce your vow.");
            return 1;
        }
        if ($text =~ /^(train|buyaa|aainfo|balance)/i) {
            $client->Message($COLOR_RED, "The Tomeless do not seek cross-class knowledge.");
            return 1;
        }
    }

    if ($text =~ /hail/i) {
        my %bal = GetAllBalances($client, $trainer_class);
        my $unique_aa_count = GetUniqueAACount($client);
        my $aa_limit_color = '#00FF00';
        if ($unique_aa_count >= 300) {
            $aa_limit_color = '#FF4444';
        } elsif ($unique_aa_count >= 275) {
            $aa_limit_color = '#FFFF00';
        }
        
        my $popup = "<c \"#00FFFF\">$class_name AA Training</c><br><br>";
        $popup .= "<c \"#FFFF00\">AA Limit Notice:</c><br>";
        $popup .= "The RoF2 client can only safely track about <c \"#FFFFFF\">300 unique AA lines</c> per character.<br>";
        $popup .= "You currently have <c \"$aa_limit_color\">$unique_aa_count / 300</c> unique AA lines.<br>";
        $popup .= "We are consolidating duplicate and overlapping AA lines to make room while preserving their value.<br><br>";
        $popup .= "<c \"#FFFF00\">How It Works:</c><br>";
        $popup .= "1. Bring me <c \"#FFD700\">illegible $class_name tomes</c> + platinum<br>";
        $popup .= "2. I will decipher them and grant you <c \"#00FF00\">training credits</c><br>";
        $popup .= "3. Use credits to purchase cross-class abilities<br><br>";
        $popup .= "<c \"#FFFF00\">Credit Costs:</c><br>";
        $popup .= "- <c \"#00FF00\">Greater Tome</c> + 100pp = 1 Greater Credit<br>";
        $popup .= "- <c \"#00CCFF\">Exalted Tome</c> + 300pp = 1 Exalted Credit<br>";
        $popup .= "- <c \"#CC66FF\">Ascendant Tome</c> + 500pp = 1 Ascendant Credit<br><br>";
        $popup .= "<c \"#FFFF00\">Your Credits:</c><br>";
        $popup .= "- <c \"#00FF00\">Greater:</c> <c \"#FFFFFF\">$bal{1}</c><br>";
        $popup .= "- <c \"#00CCFF\">Exalted:</c> <c \"#FFFFFF\">$bal{2}</c><br>";
        $popup .= "- <c \"#CC66FF\">Ascendant:</c> <c \"#FFFFFF\">$bal{3}</c><br><br>";
        $popup .= "<c \"#AAAAAA\">Each credit buys one rank of its tier. Native class abilities use your original AA — cross-class abilities use the universal version.</c>";
        
        quest::popup("$class_name Training", $popup, 0, 0, 0);
        $client->Message($COLOR_HEADING, "Browse: " . quest::saylink("train t1 0", 1, "[Greater]") . "   " . quest::saylink("train t2 0", 1, "[Exalted]") . "   " . quest::saylink("train t3 0", 1, "[Ascendant]"));
        return 1;
    }

    if ($text =~ /^balance$/i) {
        ShowBalance($client, $trainer_class);
        return 1;
    }

    # train [filter] [page]
    if ($text =~ /^train(?:\s+(all|t1|t2|t3))?(?:\s+(\d+))?$/i) {
        my $filter_key = lc($1 || 'all');
        my $page = int($2 || 0);
        my $filter = '';
        $filter = '1' if $filter_key eq 't1';
        $filter = '2' if $filter_key eq 't2';
        $filter = '3' if $filter_key eq 't3';
        ShowTrainingMenu($client, $page, $filter, $trainer_class);
        return 1;
    }

    # aainfo <uid>
    if ($text =~ /^aainfo\s+(\d+)$/i) {
        ShowAADetail($client, int($1), $trainer_class);
        return 1;
    }

    # buyaa <uid> — show confirmation popup
    if ($text =~ /^buyaa\s+(\d+)$/i) {
        ShowBuyConfirmation($client, int($1), $trainer_class);
        return 1;
    }

    return 0;
}

# ============================================================
# Helper: Check if player can buy next rank (balance + level + prereqs)
# Returns 1 if all conditions met, 0 otherwise
# ============================================================
sub _check_can_buy {
    my ($dbh, $client, $first_rank_id, $current_rank, $balance, $insight_cost) = @_;

    # Check balance
    if ($balance < $insight_cost) {
        quest::debug("_check_can_buy: FAIL - insufficient balance ($balance < $insight_cost)");
        return 0;
    }

    # Get next rank ID
    my $next_rank_id = _get_nth_rank_id($dbh, $first_rank_id, $current_rank);
    unless ($next_rank_id) {
        quest::debug("_check_can_buy: FAIL - cannot find next rank (first_rank=$first_rank_id, current=$current_rank)");
        return 0;
    }
    quest::debug("_check_can_buy: next_rank_id=$next_rank_id");

    # Check level requirement
    my ($level_req) = $dbh->selectrow_array(
        "SELECT level_req FROM aa_ranks WHERE id = ?", undef, $next_rank_id
    );
    if ($level_req && $level_req > 0 && $client->GetLevel() < $level_req) {
        quest::debug("_check_can_buy: FAIL - level too low (need $level_req, have " . $client->GetLevel() . ")");
        return 0;
    }

    # Check prerequisites, accepting explicit original/universal mapping pairs in either direction.
    my $pre_sth = $dbh->prepare(
        "SELECT rp.aa_id, rp.points FROM aa_rank_prereqs rp WHERE rp.rank_id = ?"
    );
    $pre_sth->execute($next_rank_id);
    while (my ($prereq_aa, $prereq_points) = $pre_sth->fetchrow_array()) {
        my ($prereq_first_rank_direct) = $dbh->selectrow_array(
            "SELECT first_rank_id FROM aa_ability WHERE id = ?", undef, $prereq_aa
        );
        my ($prereq_first_rank_alt) = $dbh->selectrow_array(
            "SELECT CASE WHEN acm.original_aa_id = ? THEN ua.first_rank_id ELSE oa.first_rank_id END " .
            "FROM aa_custom_mapping acm " .
            "JOIN aa_ability ua ON ua.id = acm.universal_aa_id " .
            "JOIN aa_ability oa ON oa.id = acm.original_aa_id " .
            "WHERE (acm.original_aa_id = ? OR acm.universal_aa_id = ?) " .
            "AND oa.enabled = 1 " .
            "AND ua.enabled = 1 " .
            "LIMIT 1", undef, $prereq_aa, $prereq_aa, $prereq_aa
        );
        my $rank_direct = $prereq_first_rank_direct ? $client->GetAALevel($prereq_first_rank_direct) : 0;
        my $rank_alt = $prereq_first_rank_alt ? $client->GetAALevel($prereq_first_rank_alt) : 0;
        my $player_prereq_rank = ($rank_direct > $rank_alt) ? $rank_direct : $rank_alt;
        if ($player_prereq_rank < $prereq_points) {
            quest::debug("_check_can_buy: FAIL - missing prereq AA $prereq_aa (need $prereq_points, have direct=$rank_direct alt=$rank_alt)");
            $pre_sth->finish();
            return 0;
        }
    }
    $pre_sth->finish();

    quest::debug("_check_can_buy: PASS - all checks passed");
    return 1;
}

# ============================================================
# Helper: Count total ranks by walking chain
# ============================================================
sub _count_ranks {
    my ($dbh, $first_rank_id) = @_;
    return 0 unless $first_rank_id && $first_rank_id > 0;

    my $count = 0;
    my $current = $first_rank_id;
    my $safety = 0;

    while ($current && $current > 0 && $safety < 100) {
        $count++;
        my ($next) = $dbh->selectrow_array(
            "SELECT next_id FROM aa_ranks WHERE id = ?", undef, $current
        );
        last unless $next && $next > 0;
        $current = $next;
        $safety++;
    }
    return $count;
}

# ============================================================
# Helper: Get the rank_id for rank N (0-indexed from first_rank)
# ============================================================
sub _get_nth_rank_id {
    my ($dbh, $first_rank_id, $n) = @_;
    return undef unless $first_rank_id && $first_rank_id > 0;

    my $current = $first_rank_id;
    for (my $i = 0; $i < $n; $i++) {
        my ($next) = $dbh->selectrow_array(
            "SELECT next_id FROM aa_ranks WHERE id = ?", undef, $current
        );
        return undef unless $next && $next > 0;
        $current = $next;
    }
    return $current;
}

return 1;
