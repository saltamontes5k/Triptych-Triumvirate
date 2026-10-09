# Avatar of Mithaniel Marr -- Rank II "Deity Favor" giver (blessing tree 208).
# Task assignment + flavor only: the rank is granted by EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank (single-authority design).

my $TREE = 208;

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
        plugin::Whisper("You honor me, mortal. I raise my mug to you.");
    } elsif (!(plugin::BlessingIsAgnostic($deity) || $deity == $TREE)) {
        plugin::Whisper("The god I serve is not the god that binds you, $name.");
    } elsif (plugin::BlessingAssignRank2($client, $TREE)) {
            _bless_give($client, 976210, 1);
        plugin::Whisper("Ten spectres of evil fester across the old world. Take the Eye of Valor and vanquish them.");
    } else {
        plugin::Whisper("Your task is already upon you, $name. See it done.");
    }
}
