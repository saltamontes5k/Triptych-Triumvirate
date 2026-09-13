# Inquirer Galstat - Vergalid Mines
# The Serpent's Spine :: Wanderlust Guild
# #10 600228 Into the Mines (speak target - Regan assigns the task)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600228)) {
      quest::say("So, Master Regan sent you. I am Inquirer Galstat, and these mines go deeper than anyone knows. Explore the Flooded Caves, the Burial Chamber, and the Shrine of Zek, then report back to me.");
    }
    else {
      quest::say("I am Inquirer Galstat. The Vergalid Mines hold secrets older than the dragons themselves.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
