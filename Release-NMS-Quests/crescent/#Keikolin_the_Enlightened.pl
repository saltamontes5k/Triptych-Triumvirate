# Keikolin - Crescent Reach (Dragon's Grove)
# The Serpent's Spine :: Breath of Keikolin, ranks 1-15.
# Ranks 1-13 are earned by quest: the shared "Strengthening the Blood" tasks
# 600500-600512, offered here at level 5*N while the character holds rank N-1.
# The rank is granted on [receive] after the kill task completes.
#   600270 Breath of Keikolin XIV - Skull of Velosk (64103), Vergalid Mines
#   600271 Breath of Keikolin XV  - Head of Kellet (64104), Valdeholm
# AA: 595 (first rank id 20065). Heritage: 5 (Keikolin/Gold).

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
  my $aa = $client->GetAA(20065);
  my $next = $aa + 1;
  if ($text=~/hail/i) {
    if ($client->GetDrakkinHeritage() != 5) {
      quest::say("A voice like distant chimes. You are not of The Chalice, little one. My light shines elsewhere.");
    }
    elsif ($aa >= 13) {
      if (quest::istaskactive(600270) || quest::istaskactive(600271)
        || quest::istaskcompleted(600271)) {
        quest::say("The gold in your blood burns brighter each day, my child. Bring what I have asked, or fly.");
      }
      elsif ($client->GetLevel() >= 75 && $aa >= 14) {
        quest::say("One last trial remains to [complete] your calling. Kellet, Royal Guard Captain, hides behind the walls of Valdeholm. Bring me his head.");
      }
      elsif ($client->GetLevel() >= 70) {
        quest::say("You have fed the gold well, my child. Is it your wish to [strengthen] your calling as one of the blood of Keikolin?");
      }
      else {
        quest::say("Light remembers its own, my child.");
      }
    }
    elsif (quest::istaskactive(600499 + $next)) {
      quest::say("The lesson waits, my child. Finish the proving.");
    }
    elsif (quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      quest::say("The proving is done and the blood remembers. [Receive] the breath of Keikolin, my child." );
    }
    elsif ($client->GetLevel() < 5 * $next) {
      quest::say("Learn, little one. Enlightenment ripens at its own pace. Return when your light has grown.");
    }
    else {
      quest::say("Vasha, my child of enlightenment. Your light is a candle still, but The Chalice began as a drop. Do you wish to [prove] your calling?");
    }
  }
  if ($text=~/prove/i) {
    my $aa = $client->GetAA(20065);
    my $next = $aa + 1;
    if ($next <= 13 && $client->GetLevel() >= 5 * $next && !quest::istaskactive(600499 + $next) && !quest::istaskcompleted(600499 + $next)) {
      quest::say("Slay " . $rank_proving[$next - 1][1] . " " . $rank_proving[$next - 1][0] . " for your ancestor, and your breath of keikolin will deepen. Return to me when the proving is done.");
      quest::assigntask(600499 + $next);
    }
  }
  if ($text=~/receive/i) {
    my $aa = $client->GetAA(20065);
    my $next = $aa + 1;
    if ($next <= 13 && quest::istaskcompleted(600499 + $next) && $aa == $next - 1) {
      $client->GrantAlternateAdvancementAbility(595, $next, 1);
      quest::ding();
      quest::say("You have improved Breath of Keikolin to rank $next at a cost of 0 ability points. The light steadies in your blood, my child. You have improved Breath of Keikolin to rank $next. Go in light.");
    }
  }
  if ($text=~/strengthen/i) {
    my $aa = $client->GetAA(20065);
    if ($aa >= 13) {
      quest::say("We have found one living in the Vergalid Mines that calls itself Velosk, a crafter of the dead. It hoards its dark knowledge and teaches nothing. You must kill it, though. We cannot allow it to live. Bring me its skull, and your light will blind the darkness.");
      quest::assigntask(600270); # Breath of Keikolin XIV
    }
  }
  if ($text=~/complete/i or $text=~/head/i) {
    my $aa = $client->GetAA(20065);
    if ($aa >= 14) {
      quest::say("Kellet, Royal Guard Captain of Valdeholm, has earned my displeasure. Bring me his head and no gold in the world will stand against yours.");
      quest::assigntask(600271); # Breath of Keikolin XV
    }
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
