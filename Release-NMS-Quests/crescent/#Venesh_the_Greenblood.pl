# Venesh the Greenblood - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Venesh ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600266 Breath of Venesh XIV - Skull of Velosk (64103), Vergalid Mines
#   600267 Breath of Venesh XV  - Head of Kellet (64104), Valdeholm
# AA: 593 (first rank id 20039). Heritage: 3 (Venesh/Green).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 3) {
      quest::say("Hissss. Your blood does not run green, little one. The venom of Venesh is not for you.");
    }
    elsif (quest::istaskactive(600266) || quest::istaskactive(600267)
      || quest::istaskcompleted(600267)) {
      quest::say("Patience, my child. The green works slowly, and perfectly. Complete your hunt.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20039) >= 14 && $client->GetAA(20039) < 15) {
      quest::say("One last flower of the grave remains to be picked. Kellet, Royal Guard Captain of Valdeholm, guards a king of ice. Bring me his [head].");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20039) >= 13 && $client->GetAA(20039) < 14) {
      quest::say("Vasha, my child of the green. Your venom has ripened well. Is it your wish to [strengthen] your calling?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("The green works slowly, little one, and perfectly. Return when your venom has ripened.");
    }
    else {
      quest::say("The forest keeps its own, my child.");
    }
  }
  if ($text=~/strengthen/i) {
    quest::say("Velosk, a weaver of dead bones, infests the Vergalid Mines. His creations fester like rot in a wound. Destroy him. Bring me his skull, and your breath will wilt shields like flowers.");
    quest::assigntask(600266); # Breath of Venesh XIV
  }
  if ($text=~/head/i or $text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of Valdeholm, guards a king of ice. Bring me his head, and the last flower of the grave is yours.");
    quest::assigntask(600267); # Breath of Venesh XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Venesh 14 at a cost of 0 ability points. You receive the ability Breath of Venesh (level 14).");
    if ($client->GetAA(20039) < 14) {
      $client->GrantAlternateAdvancementAbility(593, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Venesh 15 at a cost of 0 ability points. You receive the ability Breath of Venesh (level 15). All things fall to the green in the end, my child. Go.");
    if ($client->GetAA(20039) < 15) {
      $client->GrantAlternateAdvancementAbility(593, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
