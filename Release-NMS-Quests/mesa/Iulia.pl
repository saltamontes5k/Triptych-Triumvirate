# Iulia - Goru`kar Mesa
# The Serpent's Spine :: Iulia task pair (tasks 600641-600642).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600641)) {
      quest::say("The [bushes] still stand, thick as ever. Burn them out.");
    }
    elsif (quest::istaskactive(600642)) {
      quest::say("The [wings], friend. Four of them, unspoiled.");
    }
    elsif (!quest::istaskcompleted(600641)) {
      quest::say("You there! The napaea fuss over their [bushes] like a dragon over eggs. I have a use for that.");
    }
    elsif (!quest::istaskcompleted(600642)) {
      quest::say("Now that they are angry, help me [pluck] a few wings. For science.");
    }
    else {
      quest::say("The windwillow smells of smoke and flowers. A fine day's work, $name.");
    }
  }
  if ($text=~/bushes/i && !quest::istaskactive(600641) && !quest::istaskcompleted(600641)) {
    quest::say("Slay six napaea protectors and their precious bushes will burn for weeks. Then speak with me.");
    quest::assigntask(600641);
  }
  if ($text=~/pluck/i && quest::istaskcompleted(600641) && !quest::istaskactive(600642) && !quest::istaskcompleted(600642)) {
    quest::say("Four napaea wings, fresh ones. They molt when annoyed - which you have arranged nicely.");
    quest::assigntask(600642);
  }
  if ($text=~/wings/i && quest::istaskactive(600642)) {
    quest::say("Bring them here whole. Torn wings curl, and curled wings are no good to me.");
  }
}

sub EVENT_ITEM {
  # Consume the wings only while Iulia #2 is active (task system handles
  # completion); anything else is returned by the handin system.
  if (quest::istaskactive(600642)) {
    plugin::check_handin(\%itemcount, 88133 => 4);
  }
  plugin::return_items(\%itemcount);
}
