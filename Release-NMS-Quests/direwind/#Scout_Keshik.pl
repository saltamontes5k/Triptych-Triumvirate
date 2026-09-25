# Scout Keshik - Direwind Cliffs (griffon aviary below the Ashengate gate)
# The Serpent's Spine :: Zryan #3: The Ashengate Griffins (600122).
# Completing the task flags the player for griffon transport up the cliffs.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600121)) {
      quest::say("Mind the beaks, $name. The aviary is off limits until Zryan's scouts clear the approach.");
    }
    elsif (!quest::istaskactive(600122) && !quest::istaskcompleted(600122)) {
      quest::say("Zryan sent you? Good. The griffons know the wind paths up to the gate, but they will not fly for strangers. Walk the line and make their acquaintance -- say [" . quest::saylink("griffon") . "] when you are ready.");
    }
    elsif (!quest::istaskcompleted(600122)) {
      quest::say("Hold still and let them scent you. When they trust your smell, say [" . quest::saylink("griffon") . "] and we fly.");
    }
    else {
      quest::say("The flock remembers you, $name. Say [" . quest::saylink("summon a griffon") . "] whenever you need the sky road.");
    }
  }

  if ($text=~/griffon/i) {
    if (!quest::istaskactive(600122) && !quest::istaskcompleted(600122) && quest::istaskcompleted(600121)) {
      quest::say("Walk the line, let them see you. Report back when you have made their acquaintance.");
      quest::assigntask(600122);
    }
  }

  if ($text=~/summon a griffon/i) {
    if (quest::istaskcompleted(600122)) {
      quest::say("Up you go, $name. Wings sturdier than yours have made this climb.");
      quest::emote("whistles sharply; a great griffon swoops down and bears you up the cliffs.");
      quest::movepc(405, -100.0, 2020.0, 414.0, 0);
    }
    else {
      quest::say("The flock does not know your scent yet. Finish the introductions first.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
