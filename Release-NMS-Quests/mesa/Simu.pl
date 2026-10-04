# Simu - Goru`kar Mesa
# The Serpent's Spine :: hail target for Dorina's series (tasks 600630-600631).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600630)) {
      quest::say("My day? I walk the minohten camp, mend the fences, watch the clouds gather over the falls. Ordinary things. Why do you ask?");
    }
    elsif (quest::istaskactive(600631)) {
      quest::say("A letter? For me? From. . . oh. Give me a moment.");
    }
    elsif (quest::istaskcompleted(600631)) {
      quest::say("Do not look at me like that. Some silences are worth more than speeches.");
    }
    else {
      quest::say("Mind the minohten, traveler. They are gentler than they look, mostly.");
    }
  }
}

sub EVENT_ITEM {
  # Consume the letter only while Dorina #2 is active (task system handles
  # completion); anything else is returned.
  if (quest::istaskactive(600631)) {
    plugin::check_handin(\%itemcount, 88110 => 1);
  }
  plugin::return_items(\%itemcount);
}
