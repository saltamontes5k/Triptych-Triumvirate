# Zhubis the Griffon Tamer - Direwind Cliffs
# The Serpent's Spine :: Ashengate access (The Pretender, task 600022)
# The Serpent's Spine :: Infiltrators faction arc (600320-322: Sabotage,
#    Project Disarm, The Weakest Link -- repeatable faction grind)
# The Serpent's Spine :: Ashengate East raid (600361) + Locate Drizzlorn (600360)
# Located at +960, -1045 in Direwind (south of Gatekeeper Kor, across the valley).

my @chain = (600320, 600321, 600322);

sub next_task {
  my @c = @chain;
  foreach my $t (@c) {
    return $t if !quest::istaskcompleted($t);
  }
  return $c[0];
}

sub arc_done {
  return (quest::istaskcompleted(600320) && quest::istaskcompleted(600321) && quest::istaskcompleted(600322));
}

sub offer_task {
  my $t = shift;
  if (!quest::istaskactive($t)) {
    quest::assigntask($t);
  }
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600022)) {
      quest::say("Do not draw attention to me, $name. I was born into a world for someone else's cause, meant to die for someone else's flawed beliefs. Though this has afforded me some interesting [" . quest::saylink("information") . "] that I could share.");
    }
    elsif (!quest::istaskcompleted(600013)) {
      quest::say("You have dealt with Nurtha, but the way into Ashengate is not yet yours, $name. Finish Captain Zheren's work in Sunderock Springs.");
    }
    elsif (!arc_done()) {
      my $t = next_task();
      if ($t == 600320) {
        quest::say("Sabotage is my trade, $name. The Scarlet Legion hoards drakes in the vineyards of Ashengate. Say the [" . quest::saylink("word") . "] and I will tell you how to undercut them.");
      }
      elsif ($t == 600321) {
        quest::say("Their armory arms the entire Legion. Say the [" . quest::saylink("word") . "] to learn of Project Disarm.");
      }
      else {
        quest::say("Every empire has a weak link. Say the [" . quest::saylink("word") . "] and I will show you theirs.");
      }
    }
    else {
      quest::say("You have done much for me, $name. There is one last thing: an old ally named [" . quest::saylink("Drizzlorn") . "] can open the way into Dyn`Leth's inner sanctum. Seek him out in the Direwind Cliffs.");
      if (!quest::istaskactive(600360) && !quest::istaskcompleted(600360)) {
        quest::assigntask(600360);
      }
    }
  }

  if ($text=~/information/i) {
    quest::say("The one who has been whispering into Dyn`leth's ear is no true believer. Find Nurtha Frazzlesprocket within the Vergalid Mines and learn the truth from her. Then deal with her before she deals with you.");
    if (!quest::istaskactive(600022) && !quest::istaskcompleted(600022)) {
      quest::assigntask(600022);
    }
  }

  if ($text=~/word/i) {
    if (quest::istaskcompleted(600022) && quest::istaskcompleted(600013)) {
      offer_task(next_task());
    }
    else {
      quest::say("Not yet, $name.");
    }
  }

  # request the Ashengate East raid
  if ($text=~/i am ready to challenge him/i) {
    if (quest::istaskcompleted(600022) && quest::istaskcompleted(600020)) {
      quest::say("Then the eastern wing is yours to break. Say 'enter Ashengate' at the portal when your force is gathered.");
      if (!quest::istaskactive(600361) && !quest::istaskcompleted(600361)) {
        quest::assigntask(600361);
      }
    }
    else {
      quest::say("Prove yourself first, $name. Clear the Leviathan's Lair and deal with Nurtha.");
    }
  }

  # A Complex Diversion (East single, North gate)
  if ($text=~/diversion/i) {
    if (quest::istaskcompleted(600022) && quest::istaskcompleted(600013)) {
      quest::say("While the East raid is underway, draw the First Born's eye elsewhere. Say the [" . quest::saylink("word") . "] to take on a [" . quest::saylink("diversion") . "].");
      if (!quest::istaskactive(600364) && !quest::istaskcompleted(600364)) {
        quest::assigntask(600364);
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
