# Anaglass - Sunderock Springs
# The Serpent's Spine :: Anaglass arc
# tasks: 600420 The Sunderock Geyser, 600421 The Sulfur Springs,
#        600422 Golgarun Springs, 600423 Beyond the Springs
# No prerequisite for the first task; the four run in order. The final step
# is a hail to Anderak in the Direwind Cliffs (SPEAK activity updates on hail).

my @chain = (600420, 600421, 600422);

sub arc_active {
  foreach my $t (@chain) { return 1 if quest::istaskactive($t); }
  return quest::istaskactive(600423) ? 1 : 0;
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(600423)) {
      quest::say("The springs are quieter for your work, $name. Anderak will remember it.");
    }
    elsif (arc_active()) {
      quest::say("You still have work at the springs, $name. Finish what the water demands.");
    }
    elsif (!quest::istaskcompleted(600420)) {
      quest::say("The geyser basin boils with [" . quest::saylink("drakes") . "]. Cull them for me and the springs will breathe easier.");
    }
    elsif (!quest::istaskcompleted(600421)) {
      quest::say("The sulfur bog festers to the northwest. Break the [" . quest::saylink("oozes") . "] and the bloated thing that commands them.");
    }
    elsif (!quest::istaskcompleted(600422)) {
      quest::say("The northeast springs are alive with [" . quest::saylink("scaldlings") . "]. Steam Lord Roil whips them into a frenzy.");
    }
    else {
      quest::say("The springs run clean again. Carry word to [" . quest::saylink("Anderak") . "] in the Direwind Cliffs.");
    }
  }

  if ($text=~/drakes/i && !quest::istaskcompleted(600420) && !arc_active()) {
    quest::assigntask(600420);
  }
  if ($text=~/oozes/i && quest::istaskcompleted(600420) && !quest::istaskcompleted(600421) && !arc_active()) {
    quest::assigntask(600421);
  }
  if ($text=~/scaldlings/i && quest::istaskcompleted(600421) && !quest::istaskcompleted(600422) && !arc_active()) {
    quest::assigntask(600422);
  }
  if ($text=~/anderak/i && quest::istaskcompleted(600422) && !quest::istaskcompleted(600423) && !arc_active()) {
    quest::assigntask(600423);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
