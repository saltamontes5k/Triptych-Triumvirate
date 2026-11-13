# Helper NPC for blessing task 700154 (flavor + quest item handout).
# The task has NO rod hand-in: the engine ticks the SpeakWith steps on hail,
# and completion is granted by EVENT_TASK_COMPLETE -> plugin::BlessingGrantRank.
# The rod itself is the favor's keepsake clicky -- never taken back.

sub _bless_give {
    my ($client, $item, $charges) = @_;
    return if $client->GetBucket("bless-gave-$item");
    $client->SummonItem($item, $charges || 1);
    $client->SetBucket("bless-gave-$item", 1);
}

sub EVENT_SAY {
    return unless $text =~ /hail/i;
    if ($client->IsTaskActivityActive(700154, 8)) {
        plugin::Whisper("You carried the storm well, " . $client->GetCleanName() . ". The rains sing across six lands. There is nothing to hand back -- the Rod is yours. Return to the Avatar of Karana and tell him the dry corners drink again.");
    } elsif ($client->IsTaskActive(700154)) {
        _bless_give($client, 976211, 1);
        plugin::Whisper("The storm god sent you? Here -- the True Karanite Rod of Rainfall. Carry it where the rain is needed.");
    } else {
        plugin::Whisper("The rod sings with spent storms. Return to the Avatar.");
    }
}
