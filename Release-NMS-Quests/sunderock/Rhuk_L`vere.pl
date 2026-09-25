# Rhuk L`vere - Sunderock Springs
# The Serpent's Spine :: Earthy Extermination I / II / III (600426-600428)
# Chain, level 65+. Accepting part III grants the bait used at the flooded
# pit in Vergalid (task 600428 explore step + a_bait_spot there).

my @chain = (600426, 600427, 600428);

sub next_task {
  foreach my $t (@chain) { return $t if !quest::istaskcompleted($t); }
  return 0;
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("Rhuk only trades with seasoned hunters, $name.");
      return;
    }
    my $t = next_task();
    if (quest::istaskactive(600426) || quest::istaskactive(600427) || quest::istaskactive(600428)) {
      quest::say("You have a commission from me already, $name. Get to it.");
    }
    elsif ($t == 600426) {
      quest::say("Bonesnappers, $name. Vicious things in the mines. Bring me four cuts of [" . quest::saylink("meat") . "].");
    }
    elsif ($t == 600427) {
      quest::say("Now I want [" . quest::saylink("eggs") . "]. Bonesnapper eggs, four of them. Delicacies, you understand.");
    }
    elsif ($t == 600428) {
      quest::say("There is a great fish in the flooded pit of Vergalid. Take my [" . quest::saylink("bait") . "] and finish it.");
    }
    else {
      quest::say("You have done the mines a service, $name.");
    }
  }

  if ($text=~/meat/i && !quest::istaskcompleted(600426)) {
    quest::assigntask(600426);
  }
  if ($text=~/eggs/i && quest::istaskcompleted(600426) && !quest::istaskcompleted(600427)) {
    quest::assigntask(600427);
  }
  if ($text=~/bait/i && quest::istaskcompleted(600427) && !quest::istaskcompleted(600428)) {
    if (!quest::istaskactive(600428)) {
      quest::assigntask(600428);
    }
    elsif (quest::countitem(36207) == 0 && quest::countitem(36208) == 0) {
      quest::say("Lost it, did you? Here, take another. Try not to feed it to the wrong fish.");
      quest::summonitem(36207, 1);
    }
  }
}

sub EVENT_TASKACCEPTED {
  if (defined($task_id) && $task_id == 600428 && !quest::countitem(36207)) {
    quest::summonitem(36207, 1);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
