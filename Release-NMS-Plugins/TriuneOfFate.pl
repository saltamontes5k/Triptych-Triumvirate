# Triune of Fate Custom Currency Plugin
# Alternate Currency ID: 6 (Maps to Item ID: 46779)

sub SpendTriuneOfFate {
    my $client = shift;
    my $amount = shift;
    if ($client) {
        return $client->RemoveAlternateCurrencyValue(6, $amount);
    }
    return 0;
}

sub GetTriuneOfFate {
    my $client = shift;
    if ($client) {
        return $client->GetAlternateCurrencyValue(6);
    }
    return 0;
}

sub TriuneOfFateLink {
    return quest::varlink(46779);
}

sub ApplyWorldWideBuff {
    my $spell_id = shift;
    my $duration = shift || 14400; # Default to 4 hours (14400 seconds)
    
    # Set/extend the global buff time via native C++ quest API
    my $expiration = quest::add_global_buff($spell_id, $duration);
    
    # Broadcast the blessing activation/extension to the world
    my $spell_name = quest::getspellname($spell_id);
    my $remaining_seconds = $expiration - time();
    
    if ($remaining_seconds > 0) {
        my $hours = int($remaining_seconds / 3600);
        my $minutes = int(($remaining_seconds % 3600) / 60);
        
        my $time_str = "";
        $time_str .= "$hours hours " if $hours > 0;
        $time_str .= "$minutes minutes" if $minutes > 0;
        $time_str =~ s/\s+$//; # Clean up trailing space if no minutes
        
        plugin::WorldAnnounce("A server-wide blessing of [$spell_name] has been activated/extended! Remaining duration: $time_str.");
    }
    
    # Force reload of global buffs across all zones
    quest::reload_global_buffs();
    
    return 1;
}

#
# Triune blessing counter
# -------------------------------------------------------------------
# Ben Affactor (Guild Lobby) feeds a lifetime server-wide tally:
#   * every 2,000pp donated          -> +2h to the four Triune world buffs
#   * every 4 pieces of level-0 gear -> +2h to the four Triune world buffs
# Remainders carry; only newly-crossed thresholds award. A world
# announcement is posted at most once per 24h to avoid spam.
#
my $TRIUNE_PP_PER_TICK    = 2000;
my $TRIUNE_ITEMS_PER_TICK = 4;
my $TRIUNE_TICK_SECONDS   = 7200;      # +2h per tick
my $TRIUNE_ANNOUNCE_CD    = 86400;     # at most one world announce per day
my @TRIUNE_WORLD_BUFFS    = (17779, 36856, 43002, 43005); # Luck, Power, Experience, Selo

sub TriuneBlessing_AddDonation {
    my ($client, $pp, $items) = @_;
    $pp    ||= 0;
    $items ||= 0;
    return 0 if ($pp <= 0 && $items <= 0);

    my $dbh = plugin::LoadMysql();
    return 0 unless $dbh;

    # Atomically accumulate the lifetime totals.
    my $upd = $dbh->prepare(
        "UPDATE triune_blessing_counter "
        . "SET pp_total = pp_total + ?, item_total = item_total + ? WHERE id = 1"
    );
    $upd->execute($pp, $items);
    $upd->finish();

    my $row = $dbh->selectrow_hashref(
        "SELECT pp_total, item_total, ticks_awarded, last_announced_at "
        . "FROM triune_blessing_counter WHERE id = 1"
    );
    return 0 unless $row;

    my $pp_total    = $row->{pp_total}    || 0;
    my $item_total  = $row->{item_total}  || 0;
    my $awarded     = $row->{ticks_awarded} || 0;
    my $last_annc   = $row->{last_announced_at} || 0;

    my $total_ticks = int($pp_total / $TRIUNE_PP_PER_TICK)
        + int($item_total / $TRIUNE_ITEMS_PER_TICK);
    my $delta = $total_ticks - $awarded;

    my $seconds_added = 0;
    if ($delta > 0) {
        $seconds_added = $delta * $TRIUNE_TICK_SECONDS;

        foreach my $spell_id (@TRIUNE_WORLD_BUFFS) {
            quest::add_global_buff($spell_id, $seconds_added);
        }
        quest::reload_global_buffs();

        my $tick_upd = $dbh->prepare(
            "UPDATE triune_blessing_counter SET ticks_awarded = ? WHERE id = 1"
        );
        $tick_upd->execute($total_ticks);
        $tick_upd->finish();

        # One combined world announcement at most once per day.
        if (time() - $last_annc >= $TRIUNE_ANNOUNCE_CD) {
            my $hours = int($seconds_added / 3600);
            plugin::WorldAnnounce(
                "The Triune blessing swells with Norrath's generosity! "
                . "The world buffs have been extended by ${hours} hour"
                . ($hours == 1 ? "" : "s") . "!"
            );
            my $annc_upd = $dbh->prepare(
                "UPDATE triune_blessing_counter SET last_announced_at = ? WHERE id = 1"
            );
            $annc_upd->execute(time());
            $annc_upd->finish();
        }
    }

    # Private progress feedback for the donor.
    if ($client) {
        my $pp_rem   = $pp_total   % $TRIUNE_PP_PER_TICK;
        my $item_rem = $item_total % $TRIUNE_ITEMS_PER_TICK;
        my $msg = "Your generosity strengthens the Triune blessing.";
        if ($seconds_added > 0) {
            $msg .= " All four world buffs have been extended by "
                . int($seconds_added / 3600) . "h.";
        }
        $msg .= " Progress to next +2h -- Platinum: "
            . "${pp_rem}/${TRIUNE_PP_PER_TICK}, No-level gear: "
            . "${item_rem}/${TRIUNE_ITEMS_PER_TICK}.";
        $client->Message(15, $msg);
    }

    return $delta;
}

1;
