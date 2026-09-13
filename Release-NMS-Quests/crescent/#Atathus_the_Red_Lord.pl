# Atathus the Red Lord - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Atathus ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600260 Breath of Atathus XIV  - Skull of Velosk (64103), Vergalid Mines
#   600261 Breath of Atathus XV   - Head of Kellet (64104), Valdeholm
# AA: 590 (first rank id 20000). Heritage: 0 (Atathus/Red).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 0) {
      quest::say("A rumble like a forge. You are not of my blood, little one. The flames of Atathus will not answer you.");
    }
    elsif (quest::istaskactive(600260) || quest::istaskactive(600261)
      || quest::istaskcompleted(600261)) {
      quest::say("The fire in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20000) >= 14 && $client->GetAA(20000) < 15) {
      quest::say("You have fed the flames well, my child of fire. One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20000) >= 13 && $client->GetAA(20000) < 14) {
      quest::say("Vasha, my child of flame. As feeble as you were, you have come far. Is it your wish to [strengthen] your calling as one of the blood of Atathus?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("Grow stronger, little flame. When your blood has ripened, return to me.");
    }
    else {
      quest::say("The flames of Atathus burn in your blood. Do not squander them.");
    }
  }
  if ($text=~/strengthen/i) {
    quest::say("We have found one that calls itself Velosk, a sculptor of bones, prowling the Vergalid Mines. It mocks the fire with its cold art. Kill it. Bring me its skull, and your breath will scorch the sky.");
    quest::assigntask(600260); # Breath of Atathus XIV
  }
  if ($text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of the cold king of Valdeholm, has earned my displeasure. Bring me his head and no flame in the world will stand against yours.");
    quest::assigntask(600261); # Breath of Atathus XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Atathus 14 at a cost of 0 ability points. You receive the ability Breath of Atathus (level 14).");
    if ($client->GetAA(20000) < 14) {
      $client->GrantAlternateAdvancementAbility(590, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Atathus 15 at a cost of 0 ability points. You receive the ability Breath of Atathus (level 15). You are blood of my blood, little flame. Go and burn brightly.");
    if ($client->GetAA(20000) < 15) {
      $client->GrantAlternateAdvancementAbility(590, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
