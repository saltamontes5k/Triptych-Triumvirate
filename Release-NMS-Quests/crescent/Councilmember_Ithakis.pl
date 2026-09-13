# Councilmember Ithakis - Crescent Reach
# The Serpent's Spine :: Ithakis' Challenge (task 600243)
# Gate: Prove Your Worth (600241). Gives Torch of the Red Lord (84205).
# Chain: Thatun -> training dummy -> combine torch -> Drawlyn -> Ithakis.
# Completing this quest unlocks Atathus the Red Lord for drakkin of the
# Atathus bloodline (heritage 0).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("A condescending glare is all you receive. Speak with Council Aide Mystrana before you address the Council of Six.");
    }
    elsif (!quest::istaskcompleted(600243) && !quest::istaskactive(600243)) {
      quest::say("So. You are the one who has been asking after the Council. I am Ithakis, first-born of [Atathus], the Red Lord of fire and war.");
    }
    elsif (quest::istaskactive(600243)) {
      quest::say("The torch is lit by fire of the blood. Combine it with the breath Quartermaster Thatun gives you, then bring the smith your efforts.");
    }
    else {
      quest::say("You have faced my challenge, little one. May the flames of Atathus guide you.");
    }
  }
  if ($text=~/Atathus/i) {
    quest::say("Lord Atathus is the great red dragon of war. You would do well to fear him. If you think yourself ready, I can give you a taste of his [arts].");
  }
  if ($text=~/arts/i) {
    quest::say("War and fire. The forge and the blade. If you would learn, I offer a [challenge].");
  }
  if ($text=~/challenge/i) {
    quest::say("Speak with Quartermaster Thatun by the practice dummies. Destroy a dummy with your own hands, learn what fire of the blood can do, and bring the smith Drawlyn a blade worth a dragon's gaze. Do this and you may yet address my father.");
    quest::say("Take this torch. Its flame is dead; only the breath of the Red Lord can wake it.");
    quest::summonitem(84205); # Torch of the Red Lord
    quest::assigntask(600243); # Ithakis' Challenge
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("Fine work. The banner will fly above the city. Now - have you the courage for a true [challenge]?");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  if (plugin::check_handin(\%itemcount, 84211 => 1)) { # Note to Ithakis
    quest::say("Drawlyn speaks well of you, and the blade was sound. You are granted the honor of addressing my father. Bow low, little one, and do not disgrace me.");
  }
  plugin::return_items(\%itemcount);
}
