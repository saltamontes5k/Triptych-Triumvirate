# Councilmember Reakash - Crescent Reach
# The Serpent's Spine :: Reakash's Serenity (task 600246)
# Gate: Prove Your Worth (600241). Offerings: Sample of Pure Water (84201),
# Wind Chime (84202), Jar of Mist (84203).
# Also receives Atathus' Elixir of Life (85092) for Oh Brother! (600248).
# Completing this quest unlocks Osh'vir the Windspirit for drakkin of the
# Osh'vir bloodline (heritage 2).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("The Council chambers are open only to those who have earned a place here. See Council Aide Mystrana.");
    }
    elsif (!quest::istaskcompleted(600246) && !quest::istaskactive(600246)) {
      quest::say("Welcome to the Council chambers, little one. Have you visited the [grove] yet, where the great trees grow?");
    }
    elsif (quest::istaskactive(600246)) {
      quest::say("The offerings, little one: pure water from the falls, a wind chime from Wyn'las, and the mist of the falls caught in a jar.");
    }
    else {
      quest::say("Serenity be upon you, friend.");
    }
  }
  if ($text=~/grove/i) {
    quest::say("The Dragon's Grove is the seat of the Scions of the Six, the great dragons of the Reach. Would you like to [visit] it as more than a sightseer?");
  }
  if ($text=~/visit/i) {
    quest::say("Then you must prove [worthy] of my mother, Osh'vir the Windspirit.");
  }
  if ($text=~/worthy/i) {
    quest::say("I am worthy, little one, and so are you - if you bring me offerings of serenity. Will you hear what I [require]?");
  }
  if ($text=~/require/i or $text=~/beginning/i) {
    quest::say("A sample of the purest water, drawn where the falls strike the pools of the Hollow. A wind chime from Merchant Wyn'las - he asks no charge for one. And the mist of the falls itself, caught in a jar of the windspirit. Go, then; that is the [beginning].");
    quest::assigntask(600246); # Reakash's Serenity
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("Karu dra. A fine banner for a fine city. Perhaps you would bring me offerings of [serenity] as well?");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  if (plugin::check_handin(\%itemcount, 85092 => 1)) { # Atathus' Elixir of Life
    quest::emote("takes a long sip of the elixir and winces.");
    quest::say("Burning! Boawb sent you with this, didn't he? Tell that wretch that Ithakis will hear of this! Udra, before I sneeze fire.");
    if (quest::istaskactivityactive(600248, 0)) {
      quest::updatetaskactivity(600248, 0, 1);
    }
  }
  plugin::return_items(\%itemcount);
}
