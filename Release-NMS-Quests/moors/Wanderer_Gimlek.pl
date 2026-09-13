# Wanderer Gimlek - Blightfire Moors
# The Serpent's Spine :: Wanderlust Guild
# #2 600207 The Crossroads (locate Gimlek), #3 600208 Far Afield (Gimlek assigns)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600207)) {
      quest::say("Well met, $name. I am Wanderer Gimlek. Master Vanguard Regan sent word you would be coming. Speak with me again and I will tell you of the landmarks I have found.");
    }
    elsif (!quest::istaskcompleted(600207)) {
      quest::say("Greetings, traveler. The Blightfire Moors are not kind to the unwary. If you seek the Wanderlust Guild, speak with Master Vanguard Regan in Crescent Reach.");
    }
    elsif (!quest::istaskcompleted(600208)) {
      quest::say("Ah, $name. I have walked these moors for many years, and I have found places the Guild would do well to mark. Will you [" . quest::saylink("scout the moorland") . "] with me?");
    }
    else {
      quest::say("The moors keep many secrets, $name. Walk carefully.");
    }
  }
  if ($text=~/scout the moorland/i && quest::istaskcompleted(600207) && !quest::istaskactive(600208) && !quest::istaskcompleted(600208)) {
    quest::say("Seek the gnoll mine to the south, a strange portal of wizardry, the druid ring, and the place where the Curse of the Gods was laid down. Then return to Master Vanguard Regan.");
    quest::assigntask(600208);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
