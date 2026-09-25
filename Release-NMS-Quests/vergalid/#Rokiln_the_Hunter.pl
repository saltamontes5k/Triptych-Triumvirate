# Rokiln the Hunter - Vergalid Mines
# The Serpent's Spine :: Disk of Warriors / Kings / Heroes (tasks 600060-600062)
# and Shield of the Otherworld (task 600063)
# Rewards: Disk of Warriors 53646, Disk of Heroes 53647, Disk of Kings 53648,
#          Shield of the Otherworld 53735
# Hand-ins are consumed here (plugin::check_handin) while the matching task is
# active; unclaimed or non-task items are auto-returned by the handin system.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Greeetinnngs. . . Though you be not my kindred, if you bring noble hunting trophies to honor my grave, I will tell you the [tale] of this tomb.");
  }
  if ($text=~/tale/i) {
    quest::say("For many years my ancestors held these mines, until the dragon men came. The tomb was a vestibule for giant artifacts, among them the Shield of the Otherworld. Dyn`leth smashed it and scattered its three disks among his captains. Will you return the [" . quest::saylink("Warriors") . "], [" . quest::saylink("Kings") . "], or [" . quest::saylink("Heroes") . "] disk? Or, if you would see the shield made [whole] again. . .");
  }
  if ($text=~/Warriors/i) {
    if (!quest::istaskactive(600060) && !quest::istaskcompleted(600060)) {
      quest::say("Return the six fragments of the Warriors' Disk to me here at my tomb.");
      quest::assigntask(600060);
    }
    else {
      quest::say("Bring me all six fragments of the Warriors' Disk.");
    }
  }
  if ($text=~/Kings/i) {
    if (!quest::istaskactive(600061) && !quest::istaskcompleted(600061)) {
      quest::say("Return the six fragments of the Kings' Disk to me here at my tomb.");
      quest::assigntask(600061);
    }
    else {
      quest::say("Bring me all six fragments of the Kings' Disk.");
    }
  }
  if ($text=~/Heroes/i) {
    if (!quest::istaskactive(600062) && !quest::istaskcompleted(600062)) {
      quest::say("Return the six fragments of the Heroes' Disk to me here at my tomb.");
      quest::assigntask(600062);
    }
    else {
      quest::say("Bring me all six fragments of the Heroes' Disk.");
    }
  }
  if ($text=~/whole|Otherworld/i) {
    if (quest::istaskcompleted(600060) && quest::istaskcompleted(600061) && quest::istaskcompleted(600062)) {
      if (!quest::istaskactive(600063) && !quest::istaskcompleted(600063)) {
        quest::say("The Shield of the Otherworld carried the names of every fallen warrior, hero, and king of my kindred. Bring me the three disks you have reassembled and I will join them once more.");
        quest::assigntask(600063);
      }
      else {
        quest::say("Bring me the Disks of Warriors, Kings, and Heroes, and the Shield of the Otherworld will be made whole.");
      }
    }
    else {
      quest::say("The shield cannot be joined while any of its disks lies broken. Return the [" . quest::saylink("Warriors") . "], [" . quest::saylink("Kings") . "], and [" . quest::saylink("Heroes") . "] disks first.");
    }
  }
}

sub EVENT_ITEM {
  # Fragments are only consumed while their task is active; everything else
  # (and any hand-in without an active task) is returned by the handin system.
  if (quest::istaskactive(600060)) {
    plugin::check_handin(\%itemcount, 85678 => 1);
    plugin::check_handin(\%itemcount, 85679 => 1);
    plugin::check_handin(\%itemcount, 85680 => 1);
    plugin::check_handin(\%itemcount, 85681 => 1);
    plugin::check_handin(\%itemcount, 85682 => 1);
    plugin::check_handin(\%itemcount, 85683 => 1);
  }
  if (quest::istaskactive(600061)) {
    plugin::check_handin(\%itemcount, 85690 => 1);
    plugin::check_handin(\%itemcount, 85691 => 1);
    plugin::check_handin(\%itemcount, 85692 => 1);
    plugin::check_handin(\%itemcount, 85693 => 1);
    plugin::check_handin(\%itemcount, 85694 => 1);
    plugin::check_handin(\%itemcount, 85695 => 1);
  }
  if (quest::istaskactive(600062)) {
    plugin::check_handin(\%itemcount, 85684 => 1);
    plugin::check_handin(\%itemcount, 85685 => 1);
    plugin::check_handin(\%itemcount, 85686 => 1);
    plugin::check_handin(\%itemcount, 85687 => 1);
    plugin::check_handin(\%itemcount, 85688 => 1);
    plugin::check_handin(\%itemcount, 85689 => 1);
  }
  if (quest::istaskactive(600063)) {
    plugin::check_handin(\%itemcount, 53646 => 1);
    plugin::check_handin(\%itemcount, 53647 => 1);
    plugin::check_handin(\%itemcount, 53648 => 1);
  }
}
