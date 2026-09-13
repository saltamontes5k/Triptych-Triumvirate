# Jenray, Envoy of Ro - Direwind Cliffs
# The Serpent's Spine :: Ashengate access (Severing the Strings, task 600023)
# Located in the tent just outside the lava moat to the right of the Ashengate zone.
# Requesting this task requires Zheren's first four tasks and a successful
# "Into the Leviathan's Lair" raid.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600020)) {
      quest::say("You are not ready, $name. Prove yourself in the Leviathan's Lair first.");
    }
    elsif (!quest::istaskcompleted(600023)) {
      quest::say("The Reincarnate walks again, his strings pulled by unseen hands. Do you wish to help me sever the [" . quest::saylink("strings") . "]?");
    }
    else {
      quest::say("The strings are cut. Goru will trouble us no more.");
    }
  }

  if ($text=~/strings/i) {
    if (quest::istaskcompleted(600020)) {
      if (!quest::istaskactive(600023) && !quest::istaskcompleted(600023)) {
        quest::say("Enter the Vergalid Mines. Kill the six Stone Protectors in the shrine room and destroy Goru Uldrock, the Reincarnate. This must be done alongside the assault on Vergalid himself.");
        quest::assigntask(600023);
      }
    }
    else {
      quest::say("Not yet, $name.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
