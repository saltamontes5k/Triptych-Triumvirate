# the Avatar of Quellious -- Rank II "Deity Favor" giver (blessing tree 210).
# Task assignment + flavor only: the rank is granted by EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank (single-authority design).

my $TREE = 210;

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    my $deity = plugin::BlessingCheckDeity($client);
    my $rank  = plugin::BlessingRank($client);
    return unless $text =~ /hail/i;
    if ($rank < 1) {
        plugin::Whisper("First kindle your devotion at the Keeper of Devotion in The Bazaar, $name.");
    } elsif ($rank >= 2) {
        plugin::Whisper("Peace spreads where patience is sown. Be tranquil, child.");
    } elsif (!(plugin::BlessingIsAgnostic($deity) || $deity == $TREE)) {
        plugin::Whisper("The god I serve is not the god that binds you, $name.");
    } elsif (plugin::BlessingAssignRank2($client, $TREE)) {
            _bless_give($client, 976213, 1);
            _bless_give($client, 976221, 12);
        plugin::Whisper("Anger burns across Norrath. Take my wand and these pies, and bring the hot tempers peace.");
    } else {
        plugin::Whisper("Your task is already upon you, $name. See it done.");
    }
}
