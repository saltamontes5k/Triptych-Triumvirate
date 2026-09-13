# Draton`ra, Master of the Void - Crescent Reach (grove treehouse)
# The Serpent's Spine :: Breath of Draton`ra ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600262 Breath of Draton`ra XIV - Skull of Velosk (64103), Vergalid Mines
#   600263 Breath of Draton`ra XV  - Head of Kellet (64104), Valdeholm
# AA: 591 (first rank id 20013). Heritage: 1 (Draton`ra/Black).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 1) {
      quest::say("The void keeps its own counsel, little one. You are not of my blood. Begone.");
    }
    elsif (quest::istaskactive(600262) || quest::istaskactive(600263)
      || quest::istaskcompleted(600263)) {
      quest::say("The shadows speak well of you, my child. Finish what has been asked.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20013) >= 14 && $client->GetAA(20013) < 15) {
      quest::say("One shadow yet stands between you and the fullness of the void. Kellet, Royal Guard Captain of Valdeholm, orders his knights from the light. Bring me his [head], and the last shadow will fall.");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20013) >= 13 && $client->GetAA(20013) < 14) {
      quest::say("You are wise to address me formally, my child of shadow. Do you wish to [strengthen] the blood of the void?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("Your shadow is not yet long enough, little one. Return when the void has ripened in you.");
    }
    else {
      quest::say("The void watches through your eyes, my child.");
    }
  }
  if ($text=~/strengthen/i) {
    quest::say("In the Vergalid Mines, one called Velosk stitches dead bone into mockeries of life. Such craft trespasses on the void's own domain. Destroy him. Bring me his skull, and your breath will drink the light.");
    quest::assigntask(600262); # Breath of Draton`ra XIV
  }
  if ($text=~/head/i or $text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of Valdeholm, orders his knights from the light. Bring me his head, and the last shadow will fall.");
    quest::assigntask(600263); # Breath of Draton`ra XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Draton`ra 14 at a cost of 0 ability points. You receive the ability Breath of Draton`ra (level 14).");
    if ($client->GetAA(20013) < 14) {
      $client->GrantAlternateAdvancementAbility(591, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Draton`ra 15 at a cost of 0 ability points. You receive the ability Breath of Draton`ra (level 15). The void keeps what it loves, my child. Go.");
    if ($client->GetAA(20013) < 15) {
      $client->GrantAlternateAdvancementAbility(591, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
