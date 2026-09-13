# Councilmember Vakk`dra - Crescent Reach
# The Serpent's Spine :: Vakk'dra's Shadow (task 600247)
# Gate: Prove Your Worth (600241). Shadow components: Enchanted Essence of
# Shadow (84215), Dusty Skeleton Bone (84216), Piece of Acrid Meat (84217).
# Completing this quest unlocks Draton`ra, Master of the Void, for drakkin of
# the Draton`ra bloodline (heritage 1).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("Sssss. You sstand in the chamber of the Council of Six, and you have not even proven yourself. Sssee Council Aide Mystrana, little one.");
    }
    elsif (!quest::istaskcompleted(600247) && !quest::istaskactive(600247)) {
      quest::say("You approach the shadow of my father's line. Do you wish to learn of the [change] that comes to all things?");
    }
    elsif (quest::istaskactive(600247)) {
      quest::say("Essence from the undead fisherman by the falls, a dusty bone from the top level of the city, and a piece of acrid meat from Butcher Katorr. Bring me all three.");
    }
    else {
      quest::say("The shadow keeps you, little one.");
    }
  }
  if ($text=~/change/i) {
    quest::say("All things change. Flesh fails, stone crumbles, and what was bright falls into shadow. Such knowledge has a [cost], however.");
  }
  if ($text=~/cost/i) {
    quest::say("My father is Draton`ra, Master of the Void. I walk his path. If you [dare] to walk it a little way, I will show you the first steps.");
  }
  if ($text=~/dare/i) {
    quest::say("I dare, and I am prepared. Bring me the tokens of shadow: an Enchanted Essence of Shadow from an undead fisherman near the falls of the Hollow, a Dusty Skeleton Bone from the top level of this city, and a Piece of Acrid Meat from Butcher Katorr. Return them all to me and my father's door will open to you.");
    quest::assigntask(600247); # Vakk'dra's Shadow
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("Yesss. A banner worthy of the city. My father's shadow falls lightly on you - for now. Perhaps you [dare] more?");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  plugin::return_items(\%itemcount);
}
