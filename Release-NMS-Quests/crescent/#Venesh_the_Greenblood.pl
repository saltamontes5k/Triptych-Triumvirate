# Venesh - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Venesh, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600266 Breath of Venesh XIV - Skull of Velosk (64103), Vergalid Mines
#   600267 Breath of Venesh XV  - Head of Kellet (64104), Valdeholm
# AA: 593 (first rank id 20039). Heritage: 3 (Venesh/Green).

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
  my $aa = $client->GetAA(20039);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 3) {
      quest::say("Hissss. Your blood does not run green, little one. The venom of Venesh is not for you.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600266) || quest::istaskactive(600267)
        || quest::istaskcompleted(600267)) {
        quest::say("The green in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the green well, my child. Is it your wish to [strengthen] your calling as one of the blood of Venesh?");
      }
      else {
        quest::say("The forest keeps its own, my child.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The green works slowly, my child. Finish the proving.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Venesh, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("The green works slowly, little one, and perfectly. Return when your venom has ripened.");
    }
    else {
      quest::say("Vasha, my child of the green. Your venom is young, but the green is patient. Do you wish to [prove] your calling?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20039);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of venesh will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20039);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(593, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Venesh to rank $next at a cost of 0 ability points. The venom warms in your blood, my child. You have improved Breath of Venesh to rank $next. All things fall to the green in the end.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20039);
    if ($aa >= 13) {
      quest::say("Velosk, a weaver of dead bones, infests the Vergalid Mines. His creations fester like rot in a wound. Destroy him. Bring me his skull, and your breath will wilt shields like flowers.");
      quest::assigntask(600266); # Breath of Venesh XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20039);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no green in the world will stand against yours.");
      quest::assigntask(600267); # Breath of Venesh XV
    }
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
