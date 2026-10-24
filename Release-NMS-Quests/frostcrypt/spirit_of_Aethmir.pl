# spirit of Aethmir - Frostcrypt, Throne of the Shade King
# The Serpent's Spine :: Return keepsake to the Wraithguards (task 600734)
# Keepsake items: 28688 Thontik's Blade, 28691 Aethmir's Pendent of Zek,
#                 28692 Skalmarg's Torn Leather War Banner, 28689 Aerigin's Cloak
# Turn-in: Wraithguard Sergeant Thavin in Valdeholm. Reward: Vial of Gooey Black Gel 53724

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Thank you for freeing me. I have gathered together, at great cost, the strength to stand before you for a moment. I am grateful for the sweet release you have granted me, but I ask one additional [" . quest::saylink("boon") . "].");
  }
  if ($text=~/boon/i) {
    quest::say("The shades that haunt this hallowed place care nothing for the sacred nature of what they [" . quest::saylink("stole") . "] from me.");
  }
  if ($text=~/stole/i) {
    quest::say("Find what was mine and give it to any of the Wraithguards - Sergeant Thavin stands outside these walls. They will see it home.");
    if (!quest::istaskactive(600734) && !quest::istaskcompleted(600734)) {
      quest::assigntask(600734);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
