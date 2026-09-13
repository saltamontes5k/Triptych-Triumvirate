# Pioneer Vulu - Goru`kar Mesa
# The Serpent's Spine :: Wanderlust Guild
# #6 600224 Northbound Trails (locate Vulu), #7 600225 Pie-Eyed Pipers (Vulu assigns)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600224)) {
      quest::say("Hail, $name. I am Pioneer Vulu, and these mesa trails are my home. Master Regan said you would come. Speak with me again and I will share what I have found.");
    }
    elsif (!quest::istaskcompleted(600224)) {
      quest::say("These trails are dangerous, stranger. If you seek the Wanderlust Guild, speak with Master Vanguard Regan in Crescent Reach.");
    }
    elsif (!quest::istaskcompleted(600225)) {
      quest::say("You found me. The mesa is full of wonders and perils alike. Will you [" . quest::saylink("map the mesa") . "] with me?");
    }
    else {
      quest::say("The mesa stretches on and on, $name. There is always more to see.");
    }
  }
  if ($text=~/map the mesa/i && quest::istaskcompleted(600224) && !quest::istaskactive(600225) && !quest::istaskcompleted(600225)) {
    quest::say("Visit the Minohten camp and the cave behind it, the Tuffein camp, the potameid nymphs south of the Serpent's Eye, the centaur Klassr, the Hissing Bend Bridge, and the Windwillow. Then report to Master Vanguard Regan.");
    quest::assigntask(600225);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
