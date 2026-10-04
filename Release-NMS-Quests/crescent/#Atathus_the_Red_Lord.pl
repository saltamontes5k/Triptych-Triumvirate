# Atathus - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Atathus, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600260 Breath of Atathus XIV - Skull of Velosk (64103), Vergalid Mines
#   600261 Breath of Atathus XV  - Head of Kellet (64104), Valdeholm
# AA: 590 (first rank id 20000). Heritage: 0 (Atathus/Red).

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
  my $aa = $client->GetAA(20000);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 0) {
      quest::say("A rumble like a forge. You are not of my blood, little one. The flames of Atathus will not answer you.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600260) || quest::istaskactive(600261)
        || quest::istaskcompleted(600261)) {
        quest::say("The red in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the red well, my child. Is it your wish to [strengthen] your calling as one of the blood of Atathus?");
      }
      else {
        quest::say("The flames of Atathus burn in your blood. Do not squander them.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The fire waits for no one, my child. Finish the proving.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Atathus, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("Grow stronger, little flame. When your blood has ripened, return to me.");
    }
    else {
      quest::say("Vasha, my child of flame. Your breath is young, but the fire is patient. Do you wish to [prove] your blood?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20000);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of atathus will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20000);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(590, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Atathus to rank $next at a cost of 0 ability points. The flames leap in your blood, my child. You have improved Breath of Atathus to rank $next. Feed the fire.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20000);
    if ($aa >= 13) {
      quest::say("We have found one that calls itself Velosk, a sculptor of bones, prowling the Vergalid Mines. It mocks the fire with its cold art. Kill it. Bring me its skull, and your breath will scorch the sky.");
      quest::assigntask(600260); # Breath of Atathus XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20000);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no red in the world will stand against yours.");
      quest::assigntask(600261); # Breath of Atathus XV
    }
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
    quest::say("You have improved Breath of Atathus 15 at a cost of 0 ability points. You receive the ability Breath of Atathus (level 15). The flames of Atathus are yours, my child. Go.");
    if ($client->GetAA(20000) < 15) {
      $client->GrantAlternateAdvancementAbility(590, 15, 1);
      quest::ding();
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
