# ============================================================
# Guild Master NPC - Cross-Class AA Training (Tome) System
# Trainer class is hardcoded per NPC. NMS reserves NPC class
# 20-35 for its multiclass "become a class" trainers, so these
# tome-trainers use class 127 and declare their class here.
# ============================================================
my $trainer_class = 16;

sub EVENT_SAY {
    plugin::HandleSay($client, $text, $trainer_class);
}

sub EVENT_POPUPRESPONSE {
    plugin::HandlePopupResponse($client, $popupid, $trainer_class);
}

sub EVENT_ITEM {
    my $success = plugin::HandleTomeTurnin($npc, $client, \%itemcount, $trainer_class, $platinum, $gold, $silver, $copper);
    unless ($success) {
        plugin::Whisper("I have no use for this.");
        plugin::return_items(\%itemcount);
    }
}

