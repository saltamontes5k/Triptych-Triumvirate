# Rokiln the Hunter - Vergalid Mines
# The Serpent's Spine :: Disk of Warriors / Kings / Heroes (tasks 600060-600062)
# Rewards: Disk of Warriors 53646, Disk of Heroes 53647, Disk of Kings 53648

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Greeetinnngs. . . Though you be not my kindred, if you bring noble hunting trophies to honor my grave, I will tell you the [tale] of this tomb.");
  }
  if ($text=~/tale/i) {
    quest::say("For many years my ancestors held these mines, until the dragon men came. The tomb was a vestibule for giant artifacts, among them the Shield of the Otherworld. Dyn`leth smashed it and scattered its three disks among his captains. Will you return the [" . quest::saylink("Warriors") . "], [" . quest::saylink("Kings") . "], or [" . quest::saylink("Heroes") . "] disk?");
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
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
