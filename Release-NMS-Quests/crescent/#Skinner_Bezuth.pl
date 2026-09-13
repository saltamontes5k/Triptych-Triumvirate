# Skinner Bezuth - Crescent Reach
# The Serpent's Spine :: skinning supply quests (tasks 600073-600075)
# Items: Pond Alligator Hide 54654, Pristine Bear Hide 85087, Grimy Ore 600161, Grimy Metal Bits 600162

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hold still, $name. I'm skinning. What do you want? Unless you've come to [lend a hand], in which case I might have work for you.");
  }
  if ($text=~/lend a hand/i) {
    quest::say("Aye, there's always hides to be had. I could use [" . quest::saylink("alligator hides") . "], [" . quest::saylink("bear hides") . "], or some [" . quest::saylink("ore") . "] from those grubby Mucktails.");
  }
  if ($text=~/alligator hides/i) {
    if (!quest::istaskactive(600073) && !quest::istaskcompleted(600073)) {
      quest::say("Bring me twelve pond alligator hides and I'll set you up with a fine tunic.");
      quest::assigntask(600073);
    }
  }
  if ($text=~/bear hides/i) {
    if (!quest::istaskactive(600074) && !quest::istaskcompleted(600074)) {
      quest::say("Kill ten cave bears and bring me back ten pristine hides. Don't bring me torn ones - I'll know.");
      quest::assigntask(600074);
    }
  }
  if ($text=~/ore/i) {
    if (!quest::istaskactive(600075) && !quest::istaskcompleted(600075)) {
      quest::say("The Mucktails hoard grimy ore and grimy metal bits. Kill them and bring me some, and I'll forge you a ring.");
      quest::assigntask(600075);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
