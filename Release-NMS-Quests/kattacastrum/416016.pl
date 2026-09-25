#--------------------------------------------------------------------------
# TBS Orux missions - Arcanist Tivalin (416016)
# Missions: The Source of Shissar Power (620110) and Immortal Coils
# (620111) - dz templates 6120-6121, Silyssar, New Chelsith.
#--------------------------------------------------------------------------
my %MISSIONS = (
  620110 => ["The Source of Shissar Power", "source", 10, 420,
             "The new Empress draws power from [relics] in the temples of Silyssar. Rob her of them."],
  620111 => ["Immortal Coils", "coils", 12, 420,
             "The Empress sustains her [immortal] honor guard with old rituals. Unravel them."],
);

sub EVENT_SAY {
  my $cid = $client->CharacterID();

  if ($text=~/hail/i) {
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (quest::istaskcompleted($tid) && !quest::get_data($cid . "-tbsm-$tid")) {
        quest::say("Splendid work in Silyssar! The arcanum pays in Orux - here is yours.");
        quest::summonitem(79911, $orux);
        quest::set_data($cid . "-tbsm-$tid", 1);
        return;
      }
    }
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (quest::istaskactive($tid)) {
        quest::say("$title is unfinished. Say [enter] to go back down.");
        return;
      }
    }
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (!quest::istaskcompleted($tid)) {
        quest::say($offer . " Say '$phrase' to accept.");
        return;
      }
    }
    quest::say("Silyssar holds no more secrets from you, arcanist's friend.");
    return;
  }

  foreach my $tid (sort keys %MISSIONS) {
    my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
    if ($text=~/$phrase/i) {
      if (quest::istaskcompleted($tid)) {
        quest::say("That thread is already unwound, $name.");
      } elsif (quest::istaskactive($tid)) {
        quest::say("The temples wait. Say [enter] to return.");
      } else {
        quest::assigntask($tid);
        quest::say("Go carefully. Say [enter] when prepared.");
      }
      return;
    }
  }
  if ($text=~/enter|venture|survive/i) {
    foreach my $tid (sort keys %MISSIONS) {
      if (quest::istaskactive($tid)) {
        my $zone = $MISSIONS{$tid}[3];
        $client->MovePCDynamicZone($zone, 0);
        return;
      }
    }
    quest::say("No mission, no portal, $name.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
