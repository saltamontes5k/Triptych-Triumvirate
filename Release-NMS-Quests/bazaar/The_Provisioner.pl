# The Provisioner - Bazaar gear pool NPC (npc_types.id 1120001417)
# Hands out one donated piece of gear per account every 8 hours, matched to an
# empty equipment slot the adventurer actually needs. Gear is donated to Ben
# Affactor (Guild Lobby) and stored in philanthropist_item_pool.

my $COOLDOWN_SECONDS = 8 * 60 * 60;   # 8 hours per account
my $MAX_LEVEL        = 0;             # 0 = serve adventurers of any level
my $MAX_PLAY         = 0;             # 0 = no playtime cap (minutes)
my $POOL_EXPIRY_DAYS = 30;

sub _prune_pool {
    my $dbh = plugin::LoadMysql();
    return unless $dbh;
    $dbh->do(
        "DELETE FROM philanthropist_item_pool "
        . "WHERE created_at < NOW() - INTERVAL $POOL_EXPIRY_DAYS DAY"
    );
}

sub _minutes_played {
    my ($client) = @_;
    my $dbh = plugin::LoadMysql();
    return 0 unless $dbh;
    my ($played) = $dbh->selectrow_array(
        "SELECT time_played FROM character_data WHERE id = ?",
        undef, $client->CharacterID()
    );
    return defined($played) ? $played : 0;
}

sub EVENT_SPAWN {
    _prune_pool();
}

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        _prune_pool();

        my $name = $client->GetCleanName();

        if (($MAX_LEVEL && $client->GetLevel() >= $MAX_LEVEL)
            || ($MAX_PLAY && _minutes_played($client) >= $MAX_PLAY)) {
            plugin::Whisper("I set aside gear for adventurers who are still finding their footing. "
                . "You seem well past that, $name.");
            return;
        }

        my $cd_key = "provisioner_cd_" . $client->AccountID();
        my $last = quest::get_data($cd_key);
        if ($last && (time() - $last) < $COOLDOWN_SECONDS) {
            my $remaining = $COOLDOWN_SECONDS - (time() - $last);
            my $hours = int($remaining / 3600);
            my $mins  = int(($remaining % 3600) / 60);
            plugin::Whisper("I've already given you a hand recently, $name. Come back in ${hours}h ${mins}m.");
            return;
        }

        my $result = plugin::Philanthropist_ClaimGear($client);
        if ($result > 0) {
            my $link = quest::varlink($result);
            plugin::Whisper("Here, $name. Take this $link -- it should serve you well. Wear it in good health.");
            quest::set_data($cd_key, time(), $COOLDOWN_SECONDS);
        } elsif ($result == -1) {
            plugin::Whisper("You look well-equipped already, $name. I'll keep my stock for those who need it more.");
        } elsif ($result == -2) {
            plugin::Whisper("Nothing in my stock fits you right now, $name. Check back later.");
        } else {
            plugin::Whisper("My stores are a little muddled right now. Try again shortly.");
        }
    }
}

1;
