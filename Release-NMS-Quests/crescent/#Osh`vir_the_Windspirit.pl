# Osh`vir - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Osh`vir, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600264 Breath of Osh`vir XIV - Skull of Velosk (64103), Vergalid Mines
#   600265 Breath of Osh`vir XV  - Head of Kellet (64104), Valdeholm
# AA: 592 (first rank id 20026). Heritage: 2 (Osh`vir/Blue).

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
  my $aa = $client->GetAA(20026);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 2) {
      quest::say("A gust of wind scatters dead leaves at your feet. You are not of my sky, little one. The storms of Osh`vir answer another.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600264) || quest::istaskactive(600265)
        || quest::istaskcompleted(600265)) {
        quest::say("The blue in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the blue well, my child. Is it your wish to [strengthen] your calling as one of the blood of Osh`vir?");
      }
      else {
        quest::say("The sky remembers its own, my child.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The wind will not wait forever, my child. Finish the proving.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Osh`vir, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("The wind favors patience, little one. Grow stronger, and return to me.");
    }
    else {
      quest::say("Vasha, my child of storms. Your breath is a breeze still, but storms begin small. Do you wish to [prove] your calling?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20026);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of osh`vir will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20026);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(592, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Osh`vir to rank $next at a cost of 0 ability points. The wind lifts your scales, my child. You have improved Breath of Osh`vir to rank $next. Ride the gale.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20026);
    if ($aa >= 13) {
      quest::say("In the Vergalid Mines crawls one called Velosk, who builds walls of bone to shut out the wind. Topple his craft. Bring me his skull, and your breath will howl like the mountain storm.");
      quest::assigntask(600264); # Breath of Osh`vir XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20026);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no blue in the world will stand against yours.");
      quest::assigntask(600265); # Breath of Osh`vir XV
    }
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
