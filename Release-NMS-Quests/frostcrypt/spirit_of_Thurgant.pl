# spirit of Thurgant - Frostcrypt, Throne of the Shade King
# The Serpent's Spine :: Return Firgant's Copper Ring to the Wraithguards (task 600218)
# Items: Firgant's Copper Ring 28690, Vial of Gooey Black Gel 53724

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Thank you for freeing me. I have gathered together, at great cost, the strength to stand before you for a moment. I am grateful for the sweet release you have granted me, but I ask one additional [" . quest::saylink("boon") . "].");
  }
  if ($text=~/boon/i) {
    quest::say("My people believe that to pass peacefully into the next world we must bring with us items of wealth and power. The foul shades that haunt this hallowed place care nothing for the sacred nature of these artifacts - they have [" . quest::saylink("stolen") . "] them!");
  }
  if ($text=~/stolen/i) {
    quest::say("Now that you have freed me, I will pass Beyond. Before I do, I would ask you to [" . quest::saylink("retrieve") . "] the items stolen from me and return them to my kin. Give them to any of the Wraithguards; they will deliver them.");
  }
  if ($text=~/retrieve/i) {
    if (!quest::istaskactive(600218) && !quest::istaskcompleted(600218)) {
      quest::say("Find my copper ring and the vial of black gel the shades took, and bring them to a Wraithguard.");
      quest::assigntask(600218);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
