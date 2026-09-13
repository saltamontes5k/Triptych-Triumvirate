# Osh`vir the Windspirit - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Osh`vir ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600264 Breath of Osh`vir XIV - Skull of Velosk (64103), Vergalid Mines
#   600265 Breath of Osh`vir XV  - Head of Kellet (64104), Valdeholm
# AA: 592 (first rank id 20026). Heritage: 2 (Osh`vir/Blue).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 2) {
      quest::say("A gust of wind scatters dead leaves at your feet. You are not of my sky, little one. The storms of Osh`vir answer another.");
    }
    elsif (quest::istaskactive(600264) || quest::istaskactive(600265)
      || quest::istaskcompleted(600265)) {
      quest::say("The wind sings of your deeds, my child. Finish the task and your breath will crack the sky.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20026) >= 14 && $client->GetAA(20026) < 15) {
      quest::say("The storm gathers, and one enemy yet stands beneath it. Kellet, Royal Guard Captain of Valdeholm, has never knelt to the sky. Bring me his [head].");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20026) >= 13 && $client->GetAA(20026) < 14) {
      quest::say("Vasha, my child of storms. You have ridden every gale the mountains offer. Is it your wish to [strengthen] your calling?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("The wind favors patience, little one. Grow stronger, and return to me.");
    }
    else {
      quest::say("The sky remembers its own, my child.");
    }
  }
  if ($text=~/strengthen/i) {
    quest::say("In the Vergalid Mines crawls one called Velosk, who builds walls of bone to shut out the wind. Topple his craft. Bring me his skull, and your breath will howl like the mountain storm.");
    quest::assigntask(600264); # Breath of Osh`vir XIV
  }
  if ($text=~/head/i or $text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of Valdeholm, has never knelt to the sky. Bring me his head, and every storm will know your name.");
    quest::assigntask(600265); # Breath of Osh`vir XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Osh`vir 14 at a cost of 0 ability points. You receive the ability Breath of Osh`vir (level 14).");
    if ($client->GetAA(20026) < 14) {
      $client->GrantAlternateAdvancementAbility(592, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Osh`vir 15 at a cost of 0 ability points. You receive the ability Breath of Osh`vir (level 15). Ride the storm home, my child.");
    if ($client->GetAA(20026) < 15) {
      $client->GrantAlternateAdvancementAbility(592, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
