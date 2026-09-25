# Blessing_of_the_Gods.pl
# Keeper of Devotion.
#   The Bazaar (151)     -- Rank I "Devotion": forge a fired idol and deliver it.
#   Plane of Tranquility -- Ranks II-X (not yet available): shows devotion status.
#
# Rank is granted by the task-completion path (EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank); this script only handles dialogue, assignment and
# the idol hand-in bookkeeping (single-authority design).

my $POPUP_DEVOTION    = 9500;
my $RANK1_KEEPER_ZONE = 151;   # The Bazaar

sub _bless_is_rank1_keeper { return ($zoneid == $RANK1_KEEPER_ZONE); }

# The idol may be handed in as its base form or an upgrade tier:
# Enchanted (+1,000,000) / Legendary (+2,000,000). Bases below 1,000,000 share
# the same value modulo 1,000,000 across tiers.
sub _bless_matches_idol {
    my ($item, $idol) = @_;
    return 0 unless defined $item;
    return 1 if $item == $idol;
    return 1 if $idol < 1000000 && ($item % 1000000) == $idol;
    return 0;
}

sub EVENT_SAY {
    my $deity = plugin::BlessingCheckDeity($client);
    my $dn    = plugin::BlessingDeityName($deity);
    my $rank  = plugin::BlessingRank($client);
    my $task  = plugin::BlessingRank1Task($deity);
    my $status_link = quest::saylink("devotion", 1, "devotion");
    # DEBUG (re-enable): uncomment the password branch below and change the
    # `hail` `if` back to `elsif`.
    # my $debug_pass = plugin::BlessingDebugPassword();
    # # TEMP TEST DEBUG: say the password to toggle the 100% proc override.
    # if ($debug_pass && $text =~ /\b\Q$debug_pass\E\b/i) {
    #     my $on = plugin::BlessingDebugToggle($client);
    #     plugin::Whisper($on
    #         ? "Test debug enabled: your blessings will fire on every trigger."
    #         : "Test debug disabled.");
    # }
    if ($text =~ /hail/i) {
        # Plane of Tranquility: the higher-ranks keeper (content pending).
        if (!_bless_is_rank1_keeper()) {
            if ($rank >= 1) {
                plugin::Whisper("The gods have marked you, $name. Your devotion to $dn burns at Rank $rank. The greater trials are not yet ready, but your [$status_link] is recorded.");
            } else {
                plugin::Whisper("The first spark of devotion is kindled in The Bazaar, $name. Return there to forge your idol. Show me your [$status_link]?");
            }
            return;
        }

        # The Bazaar: the Rank I keeper.
        if ($rank >= 1) {
            plugin::Whisper("The gods have marked you, $name. Your devotion to $dn burns at Rank $rank. Show me your [$status_link]?");
        } elsif (!$task) {
            plugin::Whisper("Your path is unclear to me, $name.");
        } elsif ($client->IsTaskActive($task)) {
            plugin::Whisper("Forge a fired idol of $dn and deliver it to me, $name. Your [$status_link] is recorded.");
        } else {
            plugin::BlessingAssignRank1($client);
            plugin::Whisper("Greetings, $name. Prove your devotion to $dn: forge a fired idol of your faith and deliver it to me. I have inscribed your [$status_link] upon your journal.");
        }
    }
    elsif ($text =~ /devotion/i) {
        my $html = plugin::BlessingStatusHtml($client);
        quest::popup("Keeper of Devotion", $html, $POPUP_DEVOTION, 0, 0);
    }
}

sub EVENT_POPUPRESPONSE {
    # Devotion status is informational; nothing to do on close.
    return if $popupid == $POPUP_DEVOTION;
}

sub EVENT_ITEM {
    # Only the Bazaar keeper accepts the Rank I idol; the Tranquil keeper returns it.
    if (!_bless_is_rank1_keeper()) {
        plugin::return_items(\%itemcount);
        return;
    }

    my $deity = plugin::BlessingCheckDeity($client);
    my $dn    = plugin::BlessingDeityName($deity);
    my $idol  = plugin::BlessingRank1Idol($deity);
    my $task  = plugin::BlessingRank1Task($deity);

    unless ($idol) {
        plugin::Whisper("I do not recognize the faith that guides you.");
        plugin::return_items(\%itemcount);
        return;
    }

    my $handed = _bless_matches_idol($item1, $idol)
              || _bless_matches_idol($item2, $idol)
              || _bless_matches_idol($item3, $idol)
              || _bless_matches_idol($item4, $idol);

    unless ($handed) {
        if ($client->IsTaskActive($task)) {
            plugin::Whisper("That is not the idol of your faith, $name. You must forge the fired idol of $dn.");
        } else {
            plugin::Whisper("Speak with me of your [devotion] before presenting an offering, $name.");
        }
        plugin::return_items(\%itemcount);
        return;
    }

    my $claimed = $client->GetBucket('bless-r1-claimed');
    if ($claimed && $claimed == $task) {
        plugin::Whisper("I have already accepted your offering, $name. Keep your idol.");
        plugin::return_items(\%itemcount);
        return;
    }

    unless ($client->IsTaskActive($task) || $client->IsTaskCompleted($task)) {
        plugin::Whisper("Speak with me of your [devotion] first, $name.");
        plugin::return_items(\%itemcount);
        return;
    }

    # Consume exactly one idol; any extra items are auto-returned. The Deliver
    # task activity is completed by the task system before this event runs, so
    # the rank is granted via EVENT_TASK_COMPLETE.
    plugin::check_handin(\%itemcount, $idol => 1);
    $client->SetBucket('bless-r1-claimed', $task);

    plugin::Whisper("The Keeper accepts your idol with reverence. Go, $name, and be blessed.");
    quest::ding();
}
