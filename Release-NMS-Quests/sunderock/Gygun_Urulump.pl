# Gygun Urulump - Sunderock Springs
# The Serpent's Spine :: Gygun's Last Request I (600430)
# Dying drakkin who gives you his note (87225) on accepting the task; the note
# is delivered to Captain Orenu Urulump in the Direwind Cliffs.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(600431)) {
      quest::say("You found my father's treasure. I have nothing left to give but thanks, $name.");
    }
    elsif (quest::istaskactive(600430) || quest::istaskactive(600431)) {
      quest::say("Please, $name. Take my note to Orenu, behind the Ashengate gate.");
    }
    elsif (quest::istaskcompleted(600430)) {
      quest::say("Orenu has the note. Whatever he asks of you next, do it for me.");
    }
    else {
      quest::say("You... you there. I am Gygun Urulump, and I have not long left. Take my [" .
                 quest::saylink("note") . "] to my father Orenu, past the Ashengate gate in the Direwind Cliffs. Tell him I was sorry.");
    }
  }

  if ($text=~/note/i && !quest::istaskcompleted(600430) && !quest::istaskactive(600430)) {
    quest::assigntask(600430);
  }
  elsif ($text=~/note/i && quest::istaskactive(600430) && quest::countitem(87225) == 0) {
    quest::say("You lost my note? Please, $name, take another. It is all I have left to send him.");
    quest::summonitem(87225, 1);
  }
}

sub EVENT_TASKACCEPTED {
  if (defined($task_id) && $task_id == 600430 && !quest::countitem(87225)) {
    quest::summonitem(87225, 1);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
