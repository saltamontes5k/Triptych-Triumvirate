# Councilmember Lizzrel - Crescent Reach
# The Serpent's Spine :: Lizzrel's Path (task 600244)
# Gate: Prove Your Worth (600241). Three treasures: Poisonous Nettle (84212),
# Broadleaf (84213), Drakkin Scale (84214), then deliver all three.
# Completing this quest unlocks Venesh the Greenblood for drakkin of the
# Venesh bloodline (heritage 3).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("We of the Council do not chat idly with strangers. Speak with Council Aide Mystrana and prove yourself first.");
    }
    elsif (!quest::istaskcompleted(600244) && !quest::istaskactive(600244)) {
      quest::say("Vasha, newcomer. I am Lizzrel, daughter of Venesh the Greenblood. My staff Tyshhar tells me you have been of use to the city. Are you interested in some [learning]?");
    }
    elsif (quest::istaskactive(600244)) {
      quest::say("The [nettle] hides in the sporali cave, the broadleaf grows by the dragon trees of the Grove, and a scale lies on the top floor of the inn. Bring me all three.");
    }
    else {
      quest::say("Walk with the green, friend.");
    }
  }
  if ($text=~/learning/i) {
    quest::say("Not the learning of scrolls and lectures. The drakkin way. Will you swear to hear me [truly]?");
  }
  if ($text=~/true/i) {
    quest::say("I am true to you. Kayoha, little one. And upaoshu - patience. If your eyes are [open] you will see what others miss.");
  }
  if ($text=~/see/i) {
    quest::say("Then show me you can [understand] what you see.");
  }
  if ($text=~/understand/i) {
    quest::say("Three treasures teach the drakkin ways: the sting of the [nettle], the growth of the broadleaf, and the gift of your ancestors' scale. Will you gather them for me?");
  }
  if ($text=~/nettle/i) {
    quest::say("A dark green bush in the sporali cave of the Hollow carries the Poisonous Nettle. Mind your fingers.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("Ah, a fine banner. The Grove will look well with it. Perhaps you would like to walk my [path] as well?");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  plugin::return_items(\%itemcount);
}
