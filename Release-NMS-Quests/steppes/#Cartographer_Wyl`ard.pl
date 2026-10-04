# Cartographer Wyl`ard - The Steppes
# The Serpent's Spine :: Wanderlust Guild mapping chain
# 600201 #12 Meet Your Map Maker, 600202 #13 Looking for Landmarks,
# 600203 #14 Go with the Floe, 600204 #15 Giant Steps, 600206 #17 Crypt Delving

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600201)) {
      quest::say("Who goes there? Oh - you must be from the Wanderlust Guild. Master Regan sent you? Good. I am Cartographer Wyl`ard. I have been exploring and mapping these far lands for the people of Crescent Reach.");
    }
    elsif (!quest::istaskcompleted(600202)) {
      quest::say("I noticed several possible landmarks I could use to make a map, but I was so disoriented while running away that I can't be sure of them. Will you visit the [" . quest::saylink("landmarks") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600203)) {
      quest::say("I am very [" . quest::saylink("concerned") . "]. I was with my assistant when we were chased from camp, and I fear Gilbish may be lost.");
    }
    elsif (!quest::istaskcompleted(600204)) {
      quest::say("You have been a great assistance to me. Are you ready to [" . quest::saylink("go out again") . "]?");
    }
    elsif (quest::istaskcompleted(600205) && !quest::istaskcompleted(600206)) {
      quest::say("I need to add details for a rough map of Frostcrypt. Unfortunately I am not strong enough to undertake the exploration. Would you assist me in the [" . quest::saylink("exploration of Frostcrypt") . "]?");
    }
    else {
      quest::say("You have been most amazing! I have no further duties at this time. Please return to Master Regan.");
    }
  }
  if ($text=~/landmarks/i && quest::istaskcompleted(600201) && !quest::istaskactive(600202) && !quest::istaskcompleted(600202)) {
    quest::say("Visit the Ancient Ruins, the Giant Monument, the Ruined Portal, the Sacrificial Altar, and the Grove, then report back to me.");
    quest::assigntask(600202);
  }
  if (($text=~/concerned/i || $text=~/gilbish/i) && quest::istaskcompleted(600202) && !quest::istaskactive(600203) && !quest::istaskcompleted(600203)) {
    quest::say("The plan was that if we were separated he should head straight home. I am uncertain whether he followed my wishes. Look for signs of Gilbish in the grove where our camp was, in the Icefall Glacier.");
    quest::assigntask(600203);
  }
  if ($text=~/go out again/i && quest::istaskcompleted(600203) && !quest::istaskactive(600204) && !quest::istaskcompleted(600204)) {
    quest::say("I need a rough map of Valdeholm. Cross the great bridge, visit the arena, find the Lorekeepers Pulpit, and look out from the East and West guard towers. Report back to me when you are finished.");
    quest::assigntask(600204);
  }
  if ($text=~/exploration of Frostcrypt/i && quest::istaskcompleted(600205) && !quest::istaskactive(600206) && !quest::istaskcompleted(600206)) {
    quest::say("Venture into the Entry Hall, the Shade Temple, and the Treasure Room, and bring me back what you find.");
    quest::assigntask(600206);
  }
  if ($text=~/gear/i) {
    if (quest::istaskactive(600608)) {
      quest::say("My [tools], friend. The Darkfell scattered them along the gnoll roads.");
    }
    elsif (!quest::istaskcompleted(600608)) {
      quest::say("Blast it all. My [gear] is gone - scattered across the steppes when the Darkfell ran us off the ridge.");
    }
    else {
      quest::say("My tools are back in their rolls, my maps in their tubes. An organized life is a happy life.");
    }
  }
  if ($text=~/gear/i && !quest::istaskactive(600608) && !quest::istaskcompleted(600608)) {
    quest::say("Recover my cartography tools from the Darkfell gnolls and deliver them back to me. Without my instruments I am just a wanderer with opinions.");
    quest::assigntask(600608);
  }
}

sub EVENT_ITEM {
  # Consume the cartography tools only while Scattered Gear is active (task
  # system handles completion); anything else is returned.
  if (quest::istaskactive(600608)) {
    plugin::check_handin(\%itemcount, 54659 => 1);
  }
  plugin::return_items(\%itemcount);
}
