# Gnashclaw Stonefed - Icefall Glacier
# The Serpent's Spine :: The Kobold Hearthstone (task 600716)
# Items: Chunk of the Sacred Stone 36203

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600716)) {
      quest::say("The sacred stone waits in the caves east of the wizard port, the northernmost chamber. Click the stone and carry the [" . quest::saylink("chunks") . "] to me - four will do.");
    }
    elsif (quest::istaskcompleted(600716)) {
      quest::say("The hearth burns bright again. Stonefed remember.");
    }
    else {
      quest::say("You [" . quest::saylink("I can help") . "]? The sacred stone of my people was shattered and scattered. Bring it home.");
    }
  }
  if ($text=~/I can help/i && !quest::istaskactive(600716) && !quest::istaskcompleted(600716)) {
    quest::assigntask(600716);
    quest::say("Take nothing but the stone. The caves east of the port, northernmost chamber. Four chunks, then return.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
