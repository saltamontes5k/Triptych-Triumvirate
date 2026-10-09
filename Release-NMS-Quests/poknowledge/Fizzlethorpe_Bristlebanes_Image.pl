# Fizzlethorpe Bristlebane's Image -- Rank II "Deity Favor" giver (blessing tree 205).
# Task assignment + flavor only: the rank is granted by EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank (single-authority design).

my $TREE = 205;

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
        plugin::Whisper("You found them ALL? Oh, SPLENDID! The Jester of Midst laughs with you!");
    } elsif (!(plugin::BlessingIsAgnostic($deity) || $deity == $TREE)) {
        plugin::Whisper("The god I serve is not the god that binds you, $name.");
    } elsif (plugin::BlessingAssignRank2($client, $TREE)) {
        plugin::Whisper("A party! A PARTY! Eight of my Party Machines are hiding across the old world. Find every one!");
    } else {
        plugin::Whisper("Your task is already upon you, $name. See it done.");
    }
}
