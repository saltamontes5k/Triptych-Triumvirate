# Avatar of Bertoxxulous -- Rank II "Deity Favor" giver (blessing tree 201).
# Task assignment + flavor only: the rank is granted by EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank (single-authority design).

my $TREE = 201;

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
        plugin::Whisper("The Plague Lord smiles upon your devotion.");
    } elsif (!(plugin::BlessingIsAgnostic($deity) || $deity == $TREE)) {
        plugin::Whisper("The god I serve is not the god that binds you, $name.");
    } elsif (plugin::BlessingAssignRank2($client, $TREE)) {
        plugin::Whisper("Ah, fevered one. Spread my plagues: Scheredin in East Freeport holds the jars.");
    } else {
        plugin::Whisper("Your task is already upon you, $name. See it done.");
    }
}
