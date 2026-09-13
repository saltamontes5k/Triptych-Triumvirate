# Mysaphar, Seeker of All - Crescent Reach (Dragon's Grove treehouse)
# The Serpent's Spine :: Breath of Mysaphar ranks 14 (lvl 70) and 15 (lvl 75).
# Ranks 1-13 are auto-granted by NMS_progression_utils; ranks 14-15 are
# earned by quest only.
#   600268 Breath of Mysaphar XIV - Skull of Velosk (64103), Vergalid Mines
#   600269 Breath of Mysaphar XV  - Head of Kellet (64104), Valdeholm
# AA: 594 (first rank id 20052). Heritage: 4 (Mysaphar/White).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 4) {
      quest::say("The moonfire does not recognize you, little one. You are not of my blood.");
    }
    elsif (quest::istaskactive(600268) || quest::istaskactive(600269)
      || quest::istaskcompleted(600269)) {
      quest::say("Seek, my child. The end of the hunt gleams like moonlight on snow.");
    }
    elsif ($client->GetLevel() >= 75 && $client->GetAA(20052) >= 14 && $client->GetAA(20052) < 15) {
      quest::say("One quarry remains, and then your seeking is done. Kellet, Royal Guard Captain of Valdeholm, has hidden from every light. Bring me his [head].");
    }
    elsif ($client->GetLevel() >= 70 && $client->GetAA(20052) >= 13 && $client->GetAA(20052) < 14) {
      quest::say("Vasha, my child of the moonfire. You have sought far and wide. Is it your wish to [strengthen] your calling?");
    }
    elsif ($client->GetLevel() < 70) {
      quest::say("You have not yet sought enough, little one. The moonfire ripens slowly.");
    }
    else {
      quest::say("Seek and be sought, my child.");
    }
  }
  if ($text=~/strengthen/i) {
    quest::say("One called Velosk hoards dead bones in the Vergalid Mines, pretending at creation. Unmake his pretense. Bring me his skull, and your breath will blind the sun.");
    quest::assigntask(600268); # Breath of Mysaphar XIV
  }
  if ($text=~/head/i or $text=~/complete/i) {
    quest::say("Kellet, Royal Guard Captain of Valdeholm, has hidden from every light that ever sought him. Bring me his head, and your seeking is done.");
    quest::assigntask(600269); # Breath of Mysaphar XV
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 64103 => 1)) { # Skull of Velosk
    quest::say("You have improved Breath of Mysaphar 14 at a cost of 0 ability points. You receive the ability Breath of Mysaphar (level 14).");
    if ($client->GetAA(20052) < 14) {
      $client->GrantAlternateAdvancementAbility(594, 14, 1);
      quest::ding();
    }
    return;
  }
  if (plugin::check_handin(\%itemcount, 64104 => 1)) { # Head of Kellet
    quest::say("You have improved Breath of Mysaphar 15 at a cost of 0 ability points. You receive the ability Breath of Mysaphar (level 15). You are a seeker no longer, but found. Go, child of the moonfire.");
    if ($client->GetAA(20052) < 15) {
      $client->GrantAlternateAdvancementAbility(594, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
