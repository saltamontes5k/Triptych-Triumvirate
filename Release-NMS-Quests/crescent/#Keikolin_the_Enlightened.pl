# Keikolin the Enlightened - Crescent Reach (Dragon's Grove treehouse)
# The Serpent's Spine :: Breath of Keikolin ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600270 Breath of Keikolin XIV - Skull of Velosk (64103), Vergalid Mines
#   600271 Breath of Keikolin XV  - Head of Kellet (64104), Valdeholm
# AA: 595 (first rank id 20065). Heritage: 5 (Keikolin/Gold).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 5) {
      quest::say("A voice like distant chimes. You are not of The Chalice, little one. My light shines elsewhere.");
    }
    elsif (quest::istaskactive(600270) || quest::istaskactive(600271)
      || quest::istaskcompleted(600271)) {
      quest::say("Your mind and knowledge are great, my child of The Chalice. Complete the trial set before you.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20065) >= 14 && $client->GetAA(20065) < 15) {
      quest::say("One final lesson remains. Kellet, Royal Guard Captain of Valdeholm, hoards his knowledge behind walls of ice and iron. Bring me his [head], and your education will be complete.");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20065) >= 13 && $client->GetAA(20065) < 14) {
      quest::say("Vasha, my child of enlightenment. You are born into The Chalice. Is it your wish to [fulfill] your calling as one of The Chalice?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("Learn, little one. Enlightenment ripens at its own pace. Return when your light has grown.");
    }
    else {
      quest::say("Light remembers its own, my child.");
    }
  }
  if ($text=~/fulfill/i or $text=~/strengthen/i) {
    quest::say("We have found one living in the Vergalid Mines that calls itself Velosk, a crafter of the dead. It hoards its dark knowledge and teaches nothing. You must kill it, though. We cannot allow it to live. Bring me its skull, and your light will blind the darkness.");
    quest::assigntask(600270); # Breath of Keikolin XIV
  }
  if ($text=~/head/i or $text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of Valdeholm, hoards his knowledge behind walls of ice and iron. Bring me his head, and your education will be complete.");
    quest::assigntask(600271); # Breath of Keikolin XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Keikolin 14 at a cost of 0 ability points. You receive the ability Breath of Keikolin (level 14).");
    if ($client->GetAA(20065) < 14) {
      $client->GrantAlternateAdvancementAbility(595, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Keikolin 15 at a cost of 0 ability points. You receive the ability Breath of Keikolin (level 15). Your mind and knowledge are great, little one. Go in light.");
    if ($client->GetAA(20065) < 15) {
      $client->GrantAlternateAdvancementAbility(595, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
