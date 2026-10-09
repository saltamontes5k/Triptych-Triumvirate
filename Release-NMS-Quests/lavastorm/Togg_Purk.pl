# Helper NPC for blessing task 700190 (flavor + quest item handout).
# Completion is granted by EVENT_TASK_COMPLETE -> plugin::BlessingGrantRank.

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    return unless $text =~ /hail/i;
    if ($client->IsTaskActive(700190)) {
        plugin::Whisper("You seek the Warrior's Rest? Prove it! Three of my dopplegangers wait nearby. Kill the first, then tell me.");
    } else {
        plugin::Whisper("Strong arms, strong heart. The Avatar will hear of this.");
    }
}
