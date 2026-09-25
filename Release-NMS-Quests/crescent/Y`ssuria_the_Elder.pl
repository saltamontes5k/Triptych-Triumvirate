# Y`ssuria the Elder - Crescent Reach
# The Serpent's Spine :: Infiltrators and Traitors of Ashengate faction arc (1135)
# tasks: 600300 The Sanctity of the Scale, 600301 The Agony of Uncertainty,
#        600302 The Ecstasy of Relief  (repeatable faction grind)
# Each task: explore the precipice in northern Ashengate, then return and speak to Y`ssuria.
# Requires Captain Zheren's first four tasks (600013) for Ashengate access.

my @chain = (600300, 600301, 600302);

sub next_task {
  my @c = @chain;
  foreach my $t (@c) {
    return $t if !quest::istaskcompleted($t);
  }
  return $c[0];
}

sub offer_task {
  my $t = shift;
  if (!quest::istaskactive($t)) {
    quest::assigntask($t);
  }
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600013)) {
      quest::say("The way into Ashengate is not yet open to you, $name. Complete Captain Zheren's work in Sunderock Springs first.");
    }
    else {
      my $t = next_task();
      if ($t == 600300) {
        quest::say("The Scale of Veeshan sleeps beneath the edge of the world, $name. Walk the [" . quest::saylink("precipice") . "] at the north end of Ashengate and gaze upon it. Return when you have seen it.");
      }
      elsif ($t == 600301) {
        quest::say("The truths it showed you weigh heavy, do they not? Stand once more at the [" . quest::saylink("precipice") . "] and let the Scale reveal more. Then return to me.");
      }
      else {
        quest::say("Each vigil deepens your understanding. Climb the [" . quest::saylink("precipice") . "] again, that the Scale may grant you relief from what you know. Then return.");
      }
    }
  }

  if ($text=~/precipice/i) {
    if (quest::istaskcompleted(600013)) {
      my $t = next_task();
      offer_task($t);
    }
    else {
      quest::say("Not yet, $name.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}