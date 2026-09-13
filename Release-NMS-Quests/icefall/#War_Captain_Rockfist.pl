# War Captain Rockfist - Icefall Glacier
# The Serpent's Spine :: Kill da Kobolds (task 600215)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Stupid High Elf. Rockfist not talk to High Elf, Rockfist only talk to orcs and [" . quest::saylink("kill kobolds") . "]. Rockfist not have time for High Elf.");
  }
  if ($text=~/kill kobolds/i) {
    quest::say("Kill kobolds is good, bother Rockfist is bad. If you want kill kobolds, Rockfist have [" . quest::saylink("things") . "] for you to do.");
  }
  if ($text=~/things/i) {
    if (!quest::istaskactive(600215) && !quest::istaskcompleted(600215)) {
      quest::say("Go kill da kobolds in Icefall. Come back when da kobolds are dead and Rockfist share da draught.");
      quest::assigntask(600215);
    }
    else {
      quest::say("Kobolds still alive. Go kill.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
