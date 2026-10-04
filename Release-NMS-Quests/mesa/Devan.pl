# Devan - Goru`kar Mesa
# The Serpent's Spine :: Devan task series (tasks 600636-600640).
# A smooth-talking drakkin with an endless appetite for supplies - and a
# secret. The #5 finale sends the player to Scout Madu, who is not amused.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600636)) {
      quest::say("The [supplies], friend - fruit, vegetables, beer. The minohten will not miss them.");
    }
    elsif (quest::istaskactive(600637)) {
      quest::say("Snakes, recluses, bears. The road must be [safe] for my carts.");
    }
    elsif (quest::istaskactive(600638)) {
      quest::say("[Pelts], friend! Snakes, recluses, wolves, bears. Bring me the makings of winter.");
    }
    elsif (quest::istaskactive(600639)) {
      quest::say("The [nymphs] pinch our wagons when no one watches. A lesson is in order.");
    }
    elsif (quest::istaskactive(600640)) {
      quest::say("Almost done - the [scouts] first. Then report to Madu for your pay.");
    }
    elsif (!quest::istaskcompleted(600636)) {
      quest::say("Psst. Over here. You look like someone who appreciates [opportunity].");
    }
    elsif (!quest::istaskcompleted(600637)) {
      quest::say("My [carts] keep getting gnawed. Clear the road and we both profit.");
    }
    elsif (!quest::istaskcompleted(600638)) {
      quest::say("The road is safer, but my [stores] are thin. Pelts, friend.");
    }
    elsif (!quest::istaskcompleted(600639)) {
      quest::say("There is one more [menace] we have not discussed. The nymphs.");
    }
    elsif (!quest::istaskcompleted(600640)) {
      quest::say("Last job, and a [rich] one. The minohten scouts, then Madu settles up.");
    }
    else {
      quest::say("Madu says my accounts are 'creative.' I say they are inspired. Off with you.");
    }
  }
  if ($text=~/opportunity/i && !quest::istaskactive(600636) && !quest::istaskcompleted(600636)) {
    quest::say("The minohten camp sits fat with stores - fruit, vegetables, a barrel of their short beer. Bring me one of each. Consider it. . . redistributing.");
    quest::assigntask(600636);
  }
  if ($text=~/safe/i && quest::istaskcompleted(600636) && !quest::istaskactive(600637) && !quest::istaskcompleted(600637)) {
    quest::say("Four mesa snakes, four mesa recluses, two mesa bears. Make the road boring again.");
    quest::assigntask(600637);
  }
  if ($text=~/pelts/i && quest::istaskcompleted(600637) && !quest::istaskactive(600638) && !quest::istaskcompleted(600638)) {
    quest::say("Six snakes, six recluses, two wolves, two bears. Winter is coming and I am woefully unprepared.");
    quest::assigntask(600638);
  }
  if ($text=~/nymphs/i && quest::istaskcompleted(600638) && !quest::istaskactive(600639) && !quest::istaskcompleted(600639)) {
    quest::say("Four napaea protectors, four potameid matrons, four oread protectors. Pinching wagons! The nerve.");
    quest::assigntask(600639);
  }
  if ($text=~/scouts/i && quest::istaskcompleted(600639) && !quest::istaskactive(600640) && !quest::istaskcompleted(600640)) {
    quest::say("Four Minohten scouts. Then speak with me, and see Scout Madu for your pay. He is expecting you.");
    quest::assigntask(600640);
  }
  if ($text=~/rich/i && quest::istaskactive(600640)) {
    quest::say("Well. Rich in experience, let us say. Madu is the one holding the coin.");
  }
}

sub EVENT_ITEM {
  # Consume the stolen provisions only while Devan #1 is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600636)) {
    plugin::check_handin(\%itemcount, 21790 => 1, 21791 => 1, 21792 => 1);
  }
  plugin::return_items(\%itemcount);
}
