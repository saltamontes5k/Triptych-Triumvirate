# Draton`ra - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Draton`ra, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600262 Breath of Draton`ra XIV - Skull of Velosk (64103), Vergalid Mines
#   600263 Breath of Draton`ra XV  - Head of Kellet (64104), Valdeholm
# AA: 591 (first rank id 20013). Heritage: 1 (Draton`ra/Black).

# Shared proving targets per rank: [creature display, count].
my @rank_proving = (
    ['moss vipers', 8],
    ['giant bog rats', 8],
    ['slashclaws', 10],
    ['Nokk dead', 10],
    ['Mucktail gnolls', 10],
    ['Stone Hive bixies', 12],
    ['rotwood treants', 12],
    ['ghostpack wolves', 12],
    ['moorwalkers', 12],
    ['sporali', 14],
    ['gnarl thorns', 14],
    ['hedge devils', 16],
    ['blightfire wanderers', 16],
);

sub EVENT_SAY {
  my $aa = $client->GetAA(20013);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 1) {
      quest::say("The void keeps its own counsel, little one. You are not of my blood. Begone.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600262) || quest::istaskactive(600263)
        || quest::istaskcompleted(600263)) {
        quest::say("The black in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the black well, my child. Is it your wish to [strengthen] your calling as one of the blood of Draton`ra?");
      }
      else {
        quest::say("The void watches through your eyes, my child.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The shadows grow impatient, my child. Finish the proving.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Draton`ra, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("Your shadow is not yet long enough, little one. Return when the void has ripened in you.");
    }
    else {
      quest::say("You are wise to address me formally, my child of shadow. Do you wish to [prove] the blood of the void?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20013);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of draton`ra will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20013);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(591, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Draton`ra to rank $next at a cost of 0 ability points. The shadows deepen around you, my child. You have improved Breath of Draton`ra to rank $next. The void keeps what it loves.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20013);
    if ($aa >= 13) {
      quest::say("In the Vergalid Mines, one called Velosk stitches dead bone into mockeries of life. Such craft trespasses on the void's own domain. Destroy him. Bring me his skull, and your breath will drink the light.");
      quest::assigntask(600262); # Breath of Draton`ra XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20013);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no black in the world will stand against yours.");
      quest::assigntask(600263); # Breath of Draton`ra XV
    }
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
