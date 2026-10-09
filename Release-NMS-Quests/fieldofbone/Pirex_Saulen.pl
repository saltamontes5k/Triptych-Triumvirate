# Helper NPC for blessing task 700118 (flavor + quest item handout).
# Completion is granted by EVENT_TASK_COMPLETE -> plugin::BlessingGrantRank.

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    return unless $text =~ /hail/i;
    if ($client->IsTaskActive(700118)) {
        _bless_give($client, 976222, 1);
        _bless_give($client, 976223, 1);
        _bless_give($client, 976224, 1);
        plugin::Whisper("Three wands, three fears. Doubt for the lovers of Greater Faydark, hopelessness for the mother of Erudin, forgetting for the dreamer of the Commonlands. Then the court of Antonius Bayle himself...");
    } else {
        plugin::Whisper("The seeds of fear are planted. Tell the Avatar all is done.");
    }
}
