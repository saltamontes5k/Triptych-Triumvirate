# Haliax Greycloak - AA Credit Display & Redemption NPC (Guild Lobby)
# Author: Straps
#
# Shows per-class, per-tier credit balances in a color-coded popup grid.
# Credits are stored in quest::get_data buckets keyed by character ID, tier, and class.
# Players can redeem credits for unspent AA points — either bulk (drains lowest tier first)
# or targeted by specific tier+class. Also handles buyback of old translated tomes
# from the previous system, refunding platinum and returning the illegible tome.
# Also handles tome recycling: reshape an illegible tome of any class into a random
# tome of the same tier for a different class, for the standard deciphering fee.

# ── Tome recycling constants ──
my %TIER_PLAT_COST = (1 => 100, 2 => 300, 3 => 500);
my %TIER_NAMES     = (1 => 'Greater', 2 => 'Exalted', 3 => 'Ascendant');
my %CLASS_NAMES    = (
    1  => 'Warrior',      2  => 'Cleric',       3  => 'Paladin',
    4  => 'Ranger',       5  => 'Shadow Knight', 6  => 'Druid',
    7  => 'Monk',         8  => 'Bard',          9  => 'Rogue',
    10 => 'Shaman',       11 => 'Necromancer',   12 => 'Wizard',
    13 => 'Magician',     14 => 'Enchanter',     15 => 'Beastlord',
    16 => 'Berserker',
);

sub EVENT_SAY {
    my $char_id = $client->CharacterID();
    my $is_tomeless = quest::get_data("tomeless_" . $char_id) ? 1 : 0;

    if ($text =~ /hail/i) {
        my $credits_link  = quest::saylink("my credits", 1, "my credits");
        my $recycle_link  = quest::saylink("recycle", 1, "recycle");
        my $tomeless_link = quest::saylink("the tomeless", 1, "The Tomeless");
        if ($is_tomeless) {
            my $renounce_link = quest::saylink("renounce", 1, "renounce");
            plugin::Whisper("Greetings, $name. You walk the path of The Tomeless. The old translation system has been replaced with a new [training] system, but that path is closed to you. You may [$renounce_link] your vow for 100,000 platinum, or check [$credits_link] to view your credits.");
        } else {
            plugin::Whisper("Greetings, $name. I am Haliax Greycloak, a scholar of ancient knowledge. The old translation system has been replaced with a new [training] system. You may also check [$credits_link] to view and redeem your AA training credits, or ask me to [$recycle_link] an unwanted tome into a new one. Or, if you seek a greater challenge, ask me about [$tomeless_link].");
        }
    }
    elsif ($text =~ /^the tomeless$/i) {
        if ($is_tomeless) {
            plugin::Whisper("You already walk the path of The Tomeless, $name.");
            return;
        }
        if ($ulevel > 5) {
            plugin::Whisper("The path of The Tomeless must be chosen early. You have grown too powerful — only those of level 5 or below may commit.");
            return;
        }
        # Check for any cross-class AAs (aa_ability.id > 20000)
        my $dbh = plugin::LoadMysql();
        if ($dbh) {
            my ($has_20k_aa) = $dbh->selectrow_array(
                "SELECT COUNT(*) FROM character_alternate_abilities caa " .
                "JOIN aa_ability aa ON aa.first_rank_id = caa.aa_id " .
                "WHERE caa.char_id = ? AND aa.id > 20000 AND caa.aa_value > 0",
                undef, $char_id
            );
            $dbh->disconnect();
            if ($has_20k_aa && $has_20k_aa > 0) {
                plugin::Whisper("You have already learned cross-class abilities. The path of The Tomeless is closed to you.");
                return;
            }
        }
        my $popup_text = "<c \"#FF4444\">The Tomeless — Path of the Purist</c><br><br>" .
            "<c \"#CCCCCC\">By committing to The Tomeless, you forsake the path of tomes and cross-class knowledge forever.</c><br><br>" .
            "<c \"#FFFF00\">What you gain:</c><br>" .
            "- Unique titles marking your dedication<br>" .
            "- A distinctive visual aura visible to all<br>" .
            "- The respect of those who know what it means<br><br>" .
            "<c \"#FF4444\">What you sacrifice:</c><br>" .
            "- You may never turn in tomes to guild masters<br>" .
            "- You may never learn cross-class abilities<br>" .
            "- You may never redeem tome credits<br><br>" .
            "<c \"#AAAAAA\">This vow can be renounced later for 100,000 platinum.</c><br><br>" .
            "<c \"#FFFFFF\">Are you certain you wish to walk The Tomeless path?</c>";
        quest::popup("The Tomeless", $popup_text, 9900, 1, 0);
    }
    elsif ($text =~ /^renounce$/i) {
        unless ($is_tomeless) {
            plugin::Whisper("You do not walk the path of The Tomeless, $name.");
            return;
        }
        my $cost_copper = 100_000 * 1000; # 100K plat in copper
        if ($client->GetCarriedMoney() < $cost_copper) {
            plugin::Whisper("Renouncing The Tomeless requires 100,000 platinum. You do not carry enough.");
            return;
        }
        my $popup_text = "<c \"#FFD700\">Renounce The Tomeless</c><br><br>" .
            "<c \"#CCCCCC\">You wish to abandon your vow and rejoin the path of tomes and cross-class knowledge.</c><br><br>" .
            "<c \"#FF4444\">Cost: 100,000 platinum</c><br><br>" .
            "<c \"#AAAAAA\">Your Tomeless titles will be revoked and your visual aura will fade. You will receive a new title: The Renouncer.</c><br><br>" .
            "<c \"#FFFFFF\">Are you certain?</c>";
        quest::popup("Renounce The Tomeless", $popup_text, 9901, 1, 0);
    }
    elsif ($text =~ /my credits/i) {
        _show_credits($client);
    }
    elsif ($text =~ /^redeem (\d+)$/i) {
        _do_redeem($client, $1);
    }
    elsif ($text =~ /^redeem (greater|exalted|ascendant) (\d+) (\d+)$/i) {
        _do_redeem_tier($client, lc($1), $2, $3);
    }
    elsif ($text =~ /training/i) {
        my $popup_text = "<c \"#00FFFF\">New AA Training System</c><br><br>" .
            "The guild masters of each class now offer direct training in cross-class abilities.<br><br>" .
            "<c \"#FFFF00\">How It Works:</c><br>" .
            "1. Bring <c \"#FFD700\">illegible tomes</c> + platinum to any guild master<br>" .
            "2. They will decipher the tome and grant you <c \"#00FF00\">training credits</c><br>" .
            "3. Use credits to purchase cross-class abilities from that guild master<br><br>" .
            "<c \"#FFFF00\">Credit Costs:</c><br>" .
            "- <c \"#00FF00\">Greater Tome</c> + 100pp = 1 Greater Credit<br>" .
            "- <c \"#00CCFF\">Exalted Tome</c> + 300pp = 1 Exalted Credit<br>" .
            "- <c \"#CC66FF\">Ascendant Tome</c> + 500pp = 1 Ascendant Credit<br><br>" .
            "<c \"#AAAAAA\">Each credit buys one rank of its tier. You cannot purchase your own class abilities - those are earned through experience.</c><br><br>" .
            "<c \"#FFD700\">Old Translated Tomes:</c><br>" .
            "If you have old translated tomes from the previous system, I will [buyback] them for their original cost and return the matching illegible tome.";
        quest::popup("Haliax Greycloak - AA Training", $popup_text, 0, 0, 0);
    }
    elsif ($text =~ /buyback/i) {
        plugin::Whisper("Hand me any old translated tomes and I will refund their cost and return the matching illegible tome.");
    }
    elsif ($text =~ /recycle/i) {
        plugin::Whisper("Hand me one illegible tome of any class plus the deciphering fee — Greater 100pp, Exalted 300pp, Ascendant 500pp — and I will reshape it into a random tome of the same tier for another class.");
    }
}

sub EVENT_POPUPRESPONSE {
    my $char_id = $client->CharacterID();

    # Popup 9900 = Adopt The Tomeless
    if ($popupid == 9900) {
        # Re-check eligibility
        if ($ulevel > 5) {
            plugin::Whisper("You have grown too powerful. The path of The Tomeless is closed.");
            return;
        }
        my $already = quest::get_data("tomeless_" . $char_id);
        if ($already) {
            plugin::Whisper("You already walk the path of The Tomeless.");
            return;
        }

        # Commit
        quest::set_data("tomeless_" . $char_id, 1);
        quest::enabletitle(416);
        quest::enabletitle(417);

        # Apply appearance effects immediately (guarded: not in all server builds)
        $client->SendAppearanceEffectActor(19, 6, 20, 6, 21, 6, 96, 6, 211, 6) if $client->can('SendAppearanceEffectActor');
        $client->SendAppearanceEffectActor(19, 5, 20, 5, 21, 5, 96, 5, 211, 5) if $client->can('SendAppearanceEffectActor');

        plugin::Whisper("It is done, $name. You walk the path of The Tomeless.");
        $client->Message(15, "You have committed to The Tomeless. Titles unlocked. The path of tomes is closed to you.");
        quest::we(15, "$name has committed to The Tomeless, forsaking the path of tomes and cross-class knowledge. Walk with purpose.");
    }
    # Popup 9901 = Renounce The Tomeless
    elsif ($popupid == 9901) {
        my $is_tomeless = quest::get_data("tomeless_" . $char_id) ? 1 : 0;
        unless ($is_tomeless) {
            plugin::Whisper("You do not walk the path of The Tomeless.");
            return;
        }
        my $cost_copper = 100_000 * 1000;
        if ($client->GetCarriedMoney() < $cost_copper) {
            plugin::Whisper("You do not carry 100,000 platinum.");
            return;
        }

        $client->TakeMoneyFromPP($cost_copper, 1);
        quest::delete_data("tomeless_" . $char_id);

        # Remove appearance effects (guarded: not in all server builds)
        $client->RemoveAllAppearanceEffects() if $client->can('RemoveAllAppearanceEffects');

        # Revoke Tomeless titles, grant Renouncer title
        quest::disabletitle(416) if defined &quest::disabletitle;
        quest::disabletitle(417) if defined &quest::disabletitle;
        quest::enabletitle(418);

        plugin::Whisper("Your vow has been released, $name. The path of tomes is open to you once more.");
        $client->Message(15, "You have renounced The Tomeless for 100,000 platinum. Your Tomeless titles have been revoked. The training system is available again.");
    }
}

sub EVENT_ITEM {
    # --- Tome Recycling: illegible tomes (121571-121618) ---
    my ($recycle_id) = grep { $_ >= 121571 && $_ <= 121618 } keys %itemcount;
    if ($recycle_id) {
        _do_recycle($client, $recycle_id, $platinum, $gold, $silver, $copper);
        return;
    }

    my $total_bought = 0;
    my $total_refund = 0;
    my $tier_name    = "";
    my $found_tome   = 0;

    my $dbh = plugin::LoadMysql();
    unless ($dbh) {
        plugin::Whisper("Database unavailable.");
        plugin::return_items(\%itemcount);
        return;
    }

    foreach my $item_id (keys %itemcount) {
        next unless $item_id && $item_id > 0;
        if ($item_id >= 121620 && $item_id <= 121847) {
            $found_tome = 1;

            my ($item_name, $illegible_tome_id) = $dbh->selectrow_array(
                "SELECT i.Name, acm.illegible_tome_id " .
                "FROM items i " .
                "LEFT JOIN aa_custom_mapping acm ON acm.tome_item_id = i.id " .
                "WHERE i.id = ?",
                undef, $item_id
            );

            unless ($item_name && $illegible_tome_id) {
                plugin::Whisper("Cannot find mapping for this tome. Please report this issue.");
                $dbh->disconnect();
                plugin::return_items(\%itemcount);
                return;
            }

            my $cost = 0;
            if    ($item_name =~ /\(Greater\)/i)   { $cost = 100; $tier_name = "Greater";   }
            elsif ($item_name =~ /\(Exalted\)/i)   { $cost = 200; $tier_name = "Exalted";   }
            elsif ($item_name =~ /\(Ascendant\)/i) { $cost = 500; $tier_name = "Ascendant"; }
            else {
                plugin::Whisper("Cannot determine tier for this tome. Please report this issue.");
                $dbh->disconnect();
                plugin::return_items(\%itemcount);
                return;
            }

            while (quest::handin({$item_id => 1})) {
                $client->AddMoneyToPP(0, 0, 0, $cost, 1);
                quest::summonitem($illegible_tome_id);
                $total_bought++;
                $total_refund += $cost;
            }
            last;
        }
    }

    if ($found_tome && $total_bought > 0) {
        quest::ding();
        my $plural = $total_bought > 1 ? "s" : "";
        plugin::Whisper("I have bought back $total_bought tome$plural. You received ${total_refund}pp and $total_bought illegible $tier_name tome$plural.");
    } else {
        plugin::Whisper("I have no use for this. Bring me old translated tomes for buyback, or speak to guild masters about the new training system.");
        plugin::return_items(\%itemcount);
    }

    $dbh->disconnect();
}

# -------------------------------------------------------
# _show_credits - popup showing all non-zero credit balances
# -------------------------------------------------------
sub _show_credits {
    my ($client) = @_;
    my $char_id = $client->CharacterID();
    my %tier_buckets = (1 => 'greater_credits', 2 => 'exalted_credits', 3 => 'ascendant_credits');
    my %tier_names   = (1 => 'Greater',  2 => 'Exalted',  3 => 'Ascendant');
    my %tier_colors  = (1 => '#00FF00',  2 => '#00CCFF',  3 => '#CC66FF');
    my %class_names  = (
        1  => 'Warrior',      2  => 'Cleric',       3  => 'Paladin',
        4  => 'Ranger',       5  => 'Shadow Knight', 6  => 'Druid',
        7  => 'Monk',         8  => 'Bard',          9  => 'Rogue',
        10 => 'Shaman',       11 => 'Necromancer',   12 => 'Wizard',
        13 => 'Magician',     14 => 'Enchanter',     15 => 'Beastlord',
        16 => 'Berserker',
    );

    my $total = 0;
    my %data;
    for my $class_id (1..16) {
        for my $tier (1..3) {
            my $val = int(quest::get_data("character-${char_id}-$tier_buckets{$tier}_${class_id}") || 0);
            $data{$class_id}{$tier} = $val;
            $total += $val;
        }
    }

    # Build full popup with all classes and tiers (including zeros)
    my $popup = "<c \"#FFD700\">Your AA Training Credits</c><br>"
              . "<c \"#AAAAAA\">Total: $total | Each credit = 1 unspent AA point</c><br>"
              . "<c \"#AAAAAA\">Click the numbers in chat below to redeem by tier and class.</c><br><br>";

    for my $class_id (1..16) {
        my $cname = $class_names{$class_id};
        my $row = "<c \"#FFFFFF\">$cname:</c> ";
        for my $tier (1..3) {
            my $val   = $data{$class_id}{$tier};
            my $color = $val > 0 ? $tier_colors{$tier} : '#555555';
            $row .= "<c \"$color\">$tier_names{$tier}:$val</c> ";
        }
        $popup .= "$row<br>";
    }

    $client->Popup2("Haliax Greycloak - Credits", $popup, 0, 0, 0, 0);

    # Chat lines — only classes with credits, alternating colors
    $client->Message(15, "Your AA Training Credits (Total: $total) -- click to redeem");
    my $row_num = 0;
    for my $class_id (1..16) {
        my $class_total = 0;
        for my $tier (1..3) { $class_total += $data{$class_id}{$tier}; }
        next unless $class_total > 0;

        my $line = "$class_names{$class_id}: ";
        for my $tier (1..3) {
            my $val   = $data{$class_id}{$tier};
            my $tname = $tier_names{$tier};
            my $slug  = lc($tname);
            if ($val > 0) {
                my $r1 = quest::saylink("redeem ${slug} ${class_id} 1", 1, "1");
                my $r5 = quest::saylink("redeem ${slug} ${class_id} 5", 1, "5");
                $line .= "$tname:$val ($r1|$r5)  ";
            } else {
                $line .= "$tname:$val  ";
            }
        }
        $client->Message(18, $line);
        $row_num++;
    }
}

# -------------------------------------------------------
# _show_redeem - whisper redeem options
# -------------------------------------------------------
sub _show_redeem {
    my ($client) = @_;
    my $char_id = $client->CharacterID();
    my %tier_buckets = (1 => 'greater_credits', 2 => 'exalted_credits', 3 => 'ascendant_credits');
    my $total = 0;
    for my $class_id (1..16) {
        for my $tier (1..3) {
            $total += int(quest::get_data("character-${char_id}-$tier_buckets{$tier}_${class_id}") || 0);
        }
    }
    if ($total == 0) {
        plugin::Whisper("You have no credits to redeem.");
        return;
    }
    my $r1  = quest::saylink("redeem 1",  1, "Redeem 1");
    my $r5  = quest::saylink("redeem 5",  1, "Redeem 5");
    my $r10 = quest::saylink("redeem 10", 1, "Redeem 10");
    plugin::Whisper("You have $total credits available. Each credit = 1 unspent AA point. $r1 | $r5 | $r10");
}

# -------------------------------------------------------
# _do_redeem - consume credits and award AA points
# Drains tier 1 first, then 2, then 3, across all classes
# -------------------------------------------------------
sub _do_redeem {
    my ($client, $requested) = @_;
    my $char_id = $client->CharacterID();

    if (quest::get_data("tomeless_" . $char_id)) {
        plugin::Whisper("You walk the path of The Tomeless. Tome credit redemption is not available to you.");
        return;
    }
    my %tier_buckets = (1 => 'greater_credits', 2 => 'exalted_credits', 3 => 'ascendant_credits');

    my $total = 0;
    for my $class_id (1..16) {
        for my $tier (1..3) {
            $total += int(quest::get_data("character-${char_id}-$tier_buckets{$tier}_${class_id}") || 0);
        }
    }

    if ($total == 0) {
        plugin::Whisper("You have no credits to redeem.");
        return;
    }

    my $to_redeem = $requested > $total ? $total : $requested;
    my $remaining = $to_redeem;

    for my $tier (1..3) {
        last unless $remaining > 0;
        for my $class_id (1..16) {
            last unless $remaining > 0;
            my $key = "character-${char_id}-$tier_buckets{$tier}_${class_id}";
            my $bal = int(quest::get_data($key) || 0);
            next unless $bal > 0;
            my $take = $bal >= $remaining ? $remaining : $bal;
            quest::set_data($key, $bal - $take);
            $remaining -= $take;
        }
    }

    my $redeemed = $to_redeem - $remaining;
    $client->SetAAPoints($client->GetAAPoints() + $redeemed);
    plugin::Whisper("Haliax nods. You have redeemed $redeemed credit" . ($redeemed > 1 ? "s" : "") . " for $redeemed unspent AA point" . ($redeemed > 1 ? "s" : "") . ".");
    plugin::Whisper("You only had $total credits available.") if $requested > $total;
}

# -------------------------------------------------------
# _do_redeem_tier - redeem credits from a specific tier + class
# -------------------------------------------------------
sub _do_redeem_tier {
    my ($client, $tier_slug, $class_id, $requested) = @_;
    my $char_id = $client->CharacterID();

    if (quest::get_data("tomeless_" . $char_id)) {
        plugin::Whisper("You walk the path of The Tomeless. Tome credit redemption is not available to you.");
        return;
    }
    my %slug_to_bucket = (
        'greater'   => 'greater_credits',
        'exalted'   => 'exalted_credits',
        'ascendant' => 'ascendant_credits',
    );
    my %slug_to_name = (
        'greater' => 'Greater', 'exalted' => 'Exalted', 'ascendant' => 'Ascendant',
    );
    my %class_names = (
        1  => 'Warrior',      2  => 'Cleric',       3  => 'Paladin',
        4  => 'Ranger',       5  => 'Shadow Knight', 6  => 'Druid',
        7  => 'Monk',         8  => 'Bard',          9  => 'Rogue',
        10 => 'Shaman',       11 => 'Necromancer',   12 => 'Wizard',
        13 => 'Magician',     14 => 'Enchanter',     15 => 'Beastlord',
        16 => 'Berserker',
    );

    my $bucket = $slug_to_bucket{$tier_slug};
    unless ($bucket) {
        plugin::Whisper("Unknown tier.");
        return;
    }

    my $key = "character-${char_id}-${bucket}_${class_id}";
    my $bal = int(quest::get_data($key) || 0);

    if ($bal == 0) {
        plugin::Whisper("You have no $slug_to_name{$tier_slug} credits for $class_names{$class_id}.");
        return;
    }

    my $take = $requested > $bal ? $bal : $requested;
    quest::set_data($key, $bal - $take);
    $client->SetAAPoints($client->GetAAPoints() + $take);
    plugin::Whisper("Redeemed $take $slug_to_name{$tier_slug} credit" . ($take > 1 ? "s" : "") . " ($class_names{$class_id}) for $take unspent AA point" . ($take > 1 ? "s" : "") . ". Remaining: " . ($bal - $take) . ".");
}

# -------------------------------------------------------
# _do_recycle - reshape an illegible tome (121571-121618) into
# a random tome of the same tier for a different class
# Requires exactly one tome + the tier deciphering fee.
# -------------------------------------------------------
sub _do_recycle {
    my ($client, $item_id, $plat_given, $gold_given, $silver_given, $copper_given) = @_;
    my $char_id = $client->CharacterID();

    if (quest::get_data("tomeless_" . $char_id)) {
        plugin::Whisper("You walk the path of The Tomeless. The reshaping of tomes is closed to you.");
        plugin::return_items(\%itemcount);
        return;
    }

    # Exactly one tome per trade (ignore empty trade-slot "0" keys this fork adds)
    my @handed = grep { $_ && int($_) > 0 } keys %itemcount;
    if (@handed != 1 || $itemcount{$item_id} != 1) {
        plugin::Whisper("I reshape one tome at a time, $name.");
        plugin::return_items(\%itemcount);
        return;
    }

    my ($tome_class, $tier) = _get_tome_info($item_id);
    unless ($tier) {
        plugin::Whisper("I cannot reshape that item, $name.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $fee        = $TIER_PLAT_COST{$tier};
    my $tier_name  = $TIER_NAMES{$tier};
    my $class_name = $CLASS_NAMES{$tome_class} || "Unknown";

    if (int($plat_given) != $fee || int($gold_given) != 0 || int($silver_given) != 0 || int($copper_given) != 0) {
        plugin::Whisper("Reshaping a $tier_name tome requires exactly $fee platinum and no other coin, $name.");
        plugin::return_items(\%itemcount);
        return;
    }

    # Exclusion set: the handed-in class + the player's native classes
    my %excluded;
    $excluded{$tome_class} = 1;
    my $native_bm = _get_player_class_bitmask($client);
    for my $c (1..16) {
        $excluded{$c} = 1 if $native_bm && ($native_bm & (1 << ($c - 1)));
    }

    my @candidates = grep { !$excluded{$_} } (1..16);
    unless (@candidates) {
        plugin::Whisper("There is no other class toward which I can reshape this tome, $name.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $new_class = $candidates[int(rand(@candidates))];
    my $new_item  = 121571 + ($new_class - 1) * 3 + ($tier - 1);
    my $new_name  = $CLASS_NAMES{$new_class} || "Unknown";

    if (quest::handin({$item_id => 1, "platinum" => $fee})) {
        quest::summonitem($new_item);
        quest::ding();
        plugin::Whisper("The tome's knowledge is reshaped. You receive an Illegible Tome of $tier_name $new_name Advancement.");
    } else {
        plugin::Whisper("I could not complete the reshaping, $name.");
        plugin::return_items(\%itemcount);
    }
}

# -------------------------------------------------------
# _get_tome_info - map illegible tome item id to (class, tier)
# base = 121571 + (class - 1) * 3; Greater/Exalted/Ascendant
# -------------------------------------------------------
sub _get_tome_info {
    my ($item_id) = @_;
    return (0, 0) unless ($item_id >= 121571 && $item_id <= 121618);
    my $index = $item_id - 121571;
    return (int($index / 3) + 1, ($index % 3) + 1);
}

# -------------------------------------------------------
# _get_player_class_bitmask - player's full multiclass bitmask
# -------------------------------------------------------
sub _get_player_class_bitmask {
    my ($client) = @_;
    my $bm = $client->GetClassesBitmask();
    return $bm if $bm;
    my $pc = $client->GetClass();
    return ($pc >= 1 && $pc <= 16) ? (1 << ($pc - 1)) : 0;
}

1;
