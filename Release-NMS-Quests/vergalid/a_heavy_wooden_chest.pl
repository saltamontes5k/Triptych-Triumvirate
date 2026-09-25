# a heavy wooden chest - Vergalid Mines
# Gygun's Last Request II (600431). The Urulump heirloom chest; the cave in
# which it sits was found by following Gygun's note. Hailing it completes the
# SPEAK activity.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::emote("is bound with iron and sealed with the crest of the Urulump line.");
  }
}
