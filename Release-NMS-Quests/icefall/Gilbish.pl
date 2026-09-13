# Gilbish - Icefall Glacier
# The Serpent's Spine :: Wanderlust Guild #14 (Go with the Floe, task 600203)
# Cartographer Wyl`ard's lost assistant.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Shh - is the coast clear? Are you sure? I can still hear quite a bit of howling around here. Thank the dragons you've come. I got separated from Wyl`ard when we were chased from camp. Tell him I am well and heading home!");
  }
  if ($text=~/Wyl.ard/i || $text=~/home/i) {
    quest::say("Aye. The plan was to head straight home if we were separated. I followed my wishes - now I just need to get there. Wyl`ard will be so relieved.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
