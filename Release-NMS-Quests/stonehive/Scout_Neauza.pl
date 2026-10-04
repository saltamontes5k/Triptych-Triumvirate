# Scout Neauza - Stone Hive
# The Serpent's Spine :: Scout Vreshnar #2 and #3 (tasks 600588-600589).
# Hail assigns The Saving Salve; delivering the salve completes it. Once the
# scout is cured he passes along his Muddied Bixie Plans to carry to
# Scout Vreshnar in Blightfire Moors.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600588)) {
      quest::say("The enthraller on the staircase carries a [saving salve]. Bring it before this poison finishes me!");
    }
    elsif (quest::istaskactive(600589)) {
      quest::say("The plans, such as they are, must reach [Vreshnar] in Blightfire Moors. Hurry!");
    }
    elsif (quest::istaskcompleted(600588) && !quest::istaskcompleted(600589)) {
      quest::say("What a mess I got myself into! This agent stuff is harder than it looks! I had just found this set of plans when I was attacked. I can only take this as a sign that those bixies are serious! Hurry back to Vreshnar and show him what I've found. Don't worry about me, I won't let that happen again. Ha!");
      quest::summonitem(54624);
      quest::assigntask(600589);
    }
    elsif (quest::istaskcompleted(600589)) {
      quest::say("I've still got a lot of work to take care of here, but I won't let the hive get the better of me twice.");
    }
    else {
      quest::say("Cough. . . you there! One of those enthralled bixies got the better of me. Slay the [enthraller] on the staircase and bring me the salve it carries.");
    }
  }
  if ($text=~/enthraller/i && !quest::istaskactive(600588) && !quest::istaskcompleted(600588)) {
    quest::say("Kill it and loot the salve. Mind the staircase - the guards up there answer quickly.");
    quest::assigntask(600588);
  }
}

sub EVENT_ITEM {
  # Consume the salve only while The Saving Salve is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600588)) {
    plugin::check_handin(\%itemcount, 54623 => 1);
  }
  plugin::return_items(\%itemcount);
}
