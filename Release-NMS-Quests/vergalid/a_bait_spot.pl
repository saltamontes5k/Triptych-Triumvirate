# a bait spot - Vergalid Mines (flooded pit)
# Earthy Extermination III (600428). Standing at the deep water with Rhuk's
# bait, you bait the pit and Vergalak surges up.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600428) && quest::countitem(36207) > 0) {
      quest::removeitem(36207, 1);
      quest::emote("The bait splashes into the black water. For a moment, nothing. Then the pit erupts!");
      quest::spawn2(600264, 0, 0, $npc->GetX(), $npc->GetY(), $npc->GetZ(), 0);
    }
    else {
      quest::say("The water here is deep, still, and very cold.");
    }
  }
}
