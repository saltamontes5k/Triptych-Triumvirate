# Helper NPC for blessing task 700100 (flavor + quest item handout).
# Completion is granted by EVENT_TASK_COMPLETE -> plugin::BlessingGrantRank.

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    return unless $text =~ /hail/i;
    if ($client->IsTaskActive(700100)) {
        _bless_give($client, 976225, 1);
        _bless_give($client, 976226, 1);
        _bless_give($client, 976227, 1);
        _bless_give($client, 976228, 1);
        _bless_give($client, 976229, 1);
        plugin::Whisper("Take these jars of plague, little vector. The Avatar marks the beasts; touch each one with its disease.");
    } else {
        plugin::Whisper("The diseases spread. The Avatar awaits your final report.");
    }
}
