sub CustomEventSayEntry {
    return 0;
}

sub CustomEventNPCDeathEntry {
    return 0;
}

sub CustomEventHandinEntry {
    return 0;
}

sub CustomEventNPCSpawnEntry {
    return 0;
}

sub CustomEventExpGainEntry {
    return 0;
}

sub CustomEventAAExpGainEntry {
    return 0;
}

sub CustomEventItemEquipEntry {
    return 0;
}

sub CustomEventItemUnequipEntry {
    return 0;
}

sub CustomEventDestroyEntry {
    return 0;
}

sub CustomEventItemClickCastEntry {
    return 0;
}

# Triune of Fate awards.
#
# #award [Character] [Amount] [Reason] (zone/gm_commands/award.cpp) does not
# credit currency directly; it adds Amount to the character's "TriuneOfFate-Award"
# data bucket and fires cross-zone signal 666. This hook consumes that bucket. It
# is called from global_player.pl on signal 666 and from
# plugin::CommonCharacterUpdate on every zone-in, so an award to an offline
# character lands the next time they log in.
#
# Triune of Fate is alternate currency id 6 (TRIUNE_OF_FATE_CURRENCY_ID,
# world/client.h). With Custom:EnableAccountAltCurrency on,
# AddAlternateCurrencyValue credits the account-wide balance in
# account_alt_currency.
sub UpdateTriuneOfFateAward {
    my $client = shift || plugin::val('$client');
    return 0 unless ($client && $client->IsClient());

    my $pending = $client->GetBucket('TriuneOfFate-Award');
    return 0 unless (defined $pending && $pending =~ /^\d+$/ && $pending > 0);

    $client->AddAlternateCurrencyValue(6, $pending);
    $client->DeleteBucket('TriuneOfFate-Award');
    $client->Message(15, "You have been awarded $pending Triune of Fate.");
    return 1;
}

sub DoEventRewards {
    return 0;
}

1;
