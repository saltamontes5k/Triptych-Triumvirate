# Mysaphar - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Mysaphar, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600268 Breath of Mysaphar XIV - Skull of Velosk (64103), Vergalid Mines
#   600269 Breath of Mysaphar XV  - Head of Kellet (64104), Valdeholm
# AA: 594 (first rank id 20052). Heritage: 4 (Mysaphar/White).

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
  my $aa = $client->GetAA(20052);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 4) {
      quest::say("The moonfire does not recognize you, little one. You are not of my blood.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600268) || quest::istaskactive(600269)
        || quest::istaskcompleted(600269)) {
        quest::say("The white in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the white well, my child. Is it your wish to [strengthen] your calling as one of the blood of Mysaphar?");
      }
      else {
        quest::say("Seek and be sought, my child.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The moonfire marks the trail, my child. Finish the hunt.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Mysaphar, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("You have not yet sought enough, little one. The moonfire ripens slowly.");
    }
    else {
      quest::say("Vasha, my child of the moonfire. You have sought little yet, but every hunt begins somewhere. Do you wish to [prove] your calling?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20052);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of mysaphar will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20052);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(594, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Mysaphar to rank $next at a cost of 0 ability points. The moonfire brightens in your blood, my child. You have improved Breath of Mysaphar to rank $next. Seek on.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20052);
    if ($aa >= 13) {
      quest::say("One called Velosk hoards dead bones in the Vergalid Mines, pretending at creation. Unmake his pretense. Bring me his skull, and your breath will blind the sun.");
      quest::assigntask(600268); # Breath of Mysaphar XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20052);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no white in the world will stand against yours.");
      quest::assigntask(600269); # Breath of Mysaphar XV
    }
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
