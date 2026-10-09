# Helper NPC for blessing task 700154 (flavor + quest item handout).
# Completion is granted by EVENT_TASK_COMPLETE -> plugin::BlessingGrantRank.

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    return unless $text =~ /hail/i;
    if ($client->IsTaskActive(700154)) {
        _bless_give($client, 976211, 1);
        plugin::Whisper("The storm god sent you? Here -- the True Karanite Rod of Rainfall. Carry it where the rain is needed.");
    } else {
        plugin::Whisper("The rod sings with spent storms. Return to the Avatar.");
    }
}
