#--------------------------------------------------------------------------
# TBS Orux missions - Flora Venloe (416055)
# Missions: Evidence of Unity (620105), Sea Serpents (620106),
#           The Hydromancer (620107) - dz templates 6115-6117, Thalassius.
#--------------------------------------------------------------------------
my %MISSIONS = (
  620105 => ["Evidence of Unity", "evidence", 7, 417,
             "The kedge keep [secrets], and I mean to have them."],
  620106 => ["Sea Serpents", "serpents", 8, 417,
             "Four [sea] devils rule the waters now. Thin their ranks."],
  620107 => ["The Hydromancer", "hydromancer", 9, 417,
             "A [water] mage called Xao Aulin commands the floods. End him."],
);

sub EVENT_SAY {
  my $cid = $client->CharacterID();

  if ($text=~/hail/i) {
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (quest::istaskcompleted($tid) && !quest::get_data($cid . "-tbsm-$tid")) {
        quest::say("Well done on $title! Your Orux, as promised.");
        quest::summonitem(79911, $orux);
        quest::set_data($cid . "-tbsm-$tid", 1);
        return;
      }
    }
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (quest::istaskactive($tid)) {
        quest::say("$title is still yours to finish. Say [enter] to return to Thalassius.");
        return;
      }
    }
    my $offered = 0;
    foreach my $tid (sort keys %MISSIONS) {
      my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
      if (!quest::istaskcompleted($tid)) {
        quest::say($offer . " Say '$phrase' if you will hear it.");
        $offered = 1;
        last;
      }
    }
    if (!$offered) {
      quest::say("You have done all I could ask, $name. The waters remember you.");
    }
    return;
  }

  foreach my $tid (sort keys %MISSIONS) {
    my ($title, $phrase, $orux, $zone, $offer) = @{$MISSIONS{$tid}};
    if ($text=~/$phrase/i) {
      if (quest::istaskcompleted($tid)) {
        quest::say("$title is behind you, $name.");
      } elsif (quest::istaskactive($tid)) {
        quest::say("It waits. Say [enter] to return to the caves.");
      } else {
        quest::assigntask($tid);
        quest::say("Then it is yours. Say [enter] when your group stands ready.");
      }
      return;
    }
  }
  if ($text=~/enter/i) {
    foreach my $tid (sort keys %MISSIONS) {
      if (quest::istaskactive($tid)) {
        my $zone = $MISSIONS{$tid}[3];
        $client->MovePCDynamicZone($zone, 0);
        return;
      }
    }
    quest::say("You have no mission of mine to return to, $name.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
