# Blessing_of_the_Gods.pl
# Keeper of Devotion.
#   The Bazaar (151)     -- the faithful: Rank I "Devotion" (deity idol hand-in).
#   Plane of Tranquility -- the unaligned: bind a cause, then the blank-idol
#                           Rank I quest. ONLY this keeper serves Agnostics.
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
    my $rank  = plugin::BlessingRank($client);
    my $task  = plugin::BlessingRank1Task($deity);
    my $status_link = quest::saylink("devotion", 1, "devotion");
    my $cause_link  = quest::saylink("cause", 1, "cause");
    my $to    = plugin::BlessingDevotionTo($client);   # '' for Agnostic (no god named)
    my $of    = plugin::BlessingDevotionOf($client);   # '' for Agnostic
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
    # Cause selection (Tranquil Keeper only): the label text arrives verbatim
    # from the saylinks below. An Agnostic binds a cause BEFORE Rank I.
    my $cause = plugin::BlessingCauseByKeyword($text);
    if ($cause && !_bless_is_rank1_keeper() && plugin::BlessingIsAgnostic($deity)) {
        if (plugin::BlessingCause($client)) {
            plugin::Whisper("Your path is already bound, $name. A change of cause would sever your devotion entirely.");
        } elsif (plugin::BlessingSetCause($client, $cause)) {
            quest::ding();
            if (plugin::BlessingAssignRank1($client)) {
                plugin::Whisper("Your devotion is bound. Now prove it: forge the blank idol of the Unaligned and bring it to me.");
            }
        }
        return;
    }
    if ($text =~ /cause/i) {
        if (_bless_is_rank1_keeper()) {
            plugin::Whisper("The binding of causes is the Tranquil Keeper's charge, in the Plane of Tranquility.");
            return;
        }
        unless (plugin::BlessingIsAgnostic($deity)) {
            plugin::Whisper("Causes are for the unaligned, $name. The god you serve already knows your heart.");
            return;
        }
        if (plugin::BlessingCause($client)) {
            plugin::Whisper("Your path is already bound, $name. A change of cause would sever your devotion entirely.");
            return;
        }
        my @links;
        for my $d (201 .. 216) {
            my $label = plugin::BlessingCauseLabel($d);
            push @links, quest::saylink($label, 1, $label) if $label;
        }
        plugin::Whisper("Choose the cause that binds your devotion, $name: " . join(', ', @links) . ". Choose wisely -- a change of cause severs your devotion entirely.");
        return;
    }
    if ($text =~ /hail/i) {
        # Plane of Tranquility: the keeper of the unaligned.
        if (!_bless_is_rank1_keeper()) {
            if (plugin::BlessingIsAgnostic($deity)) {
                if (!plugin::BlessingCause($client)) {
                    plugin::Whisper("You walk alone, $name, yet even the unaligned may be devoted. Name your [$cause_link] and I will bind your path. But hear me: the unaligned have no royal road to self knowledge or of this world.");
                } elsif ($rank >= 2) {
                    plugin::Whisper("Your devotion -- " . plugin::BlessingDevotionTitle($client) . " -- burns at Rank $rank. Show me your [$status_link]?");
                } elsif ($rank >= 1) {
                    plugin::Whisper("Your devotion is bound, $name. Rank II demands the favor of ALL SIXTEEN gods -- every avatar, every quest, no exceptions. Show me your [$status_link]?");
                } elsif ($client->IsTaskActive($task)) {
                    plugin::Whisper("Forge the blank idol of the Unaligned -- a potter's wheel and kiln will serve; the Plane of Knowledge tradeskill buildings will do -- and deliver it to me, $name. Your [$status_link] is recorded.");
                } else {
                    plugin::BlessingAssignRank1($client);
                    plugin::Whisper("Your path is bound. Prove it, $name: forge the blank idol of the Unaligned (potter's wheel, then kiln -- the Plane of Knowledge tradeskill buildings will do) and deliver it to me. I have inscribed your [$status_link] upon your journal.");
                }
            } elsif ($rank >= 2) {
                plugin::Whisper("The gods have marked you, $name. Your devotion$to burns at Rank $rank. Show me your [$status_link]?");
            } elsif ($rank >= 1) {
                plugin::Whisper("You carry Rank I of devotion, $name. Seek out " . plugin::BlessingFavorLocation($deity) . " and earn the deity's favor to awaken Rank II. Show me your [$status_link]?");
            } else {
                plugin::Whisper("The first spark of devotion is kindled in The Bazaar, $name. Return there to forge your idol. Show me your [$status_link]?");
            }
            return;
        }

        # The Bazaar: the keeper of the faithful.
        if (plugin::BlessingIsAgnostic($deity)) {
            plugin::Whisper("You walk alone, $name, and yours is the harder road -- the unaligned have no easy route to devotion. The Tranquil Keeper, by the Plane of Knowledge portal stones in the Plane of Tranquility, binds your cause and takes your blank idol. And know this: Rank II will demand the favor of ALL SIXTEEN gods. Every avatar. Every quest. No exceptions.");
            return;
        }
        if ($rank >= 2) {
            plugin::Whisper("The gods have marked you, $name. Your devotion$to burns at Rank $rank. Show me your [$status_link]?");
        } elsif ($rank >= 1) {
            plugin::Whisper("The gods have marked you, $name. Seek out " . plugin::BlessingFavorLocation($deity) . " and earn the deity's favor to awaken Rank II. Show me your [$status_link]?");
        } elsif (!$task) {
            plugin::Whisper("Your path is unclear to me, $name.");
        } elsif ($client->IsTaskActive($task)) {
            plugin::Whisper("Forge a fired idol$of and deliver it to me, $name. Your [$status_link] is recorded.");
        } else {
            plugin::BlessingAssignRank1($client);
            plugin::Whisper("Greetings, $name. Prove your devotion$to: forge a fired idol of your faith and deliver it to me. I have inscribed your [$status_link] upon your journal.");
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
    my $deity = plugin::BlessingCheckDeity($client);
    my $of    = plugin::BlessingDevotionOf($client);   # '' for Agnostic
    my $idol  = plugin::BlessingRank1Idol($deity);
    my $task  = plugin::BlessingRank1Task($deity);

    if (_bless_is_rank1_keeper()) {
        # The Bazaar: the faithful hand in their deity's idol here.
        if (plugin::BlessingIsAgnostic($deity)) {
            plugin::Whisper("The unaligned bring their blank idols to the Tranquil Keeper in the Plane of Tranquility, $name.");
            plugin::return_items(\%itemcount);
            return;
        }
    }
    else {
        # Plane of Tranquility: only the Agnostic blank idol is accepted here.
        unless (plugin::BlessingIsAgnostic($deity)) {
            plugin::Whisper("The idols of the faithful belong to the Keeper in The Bazaar, $name.");
            plugin::return_items(\%itemcount);
            return;
        }
        unless (plugin::BlessingCause($client)) {
            plugin::Whisper("Speak with me of your [cause] first, $name. An unbound devotion cannot be offered.");
            plugin::return_items(\%itemcount);
            return;
        }
    }

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
            plugin::Whisper("That is not the idol of your faith, $name. You must forge the fired idol$of.");
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

    plugin::Whisper("The Keeper accepts your offering with reverence. Go, $name, and be blessed.");
    quest::ding();
}
