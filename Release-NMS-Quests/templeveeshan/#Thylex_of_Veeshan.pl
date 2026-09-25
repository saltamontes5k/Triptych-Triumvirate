# Event controller for the Vulak`Aerr encounter in the Temple of Veeshan.
#
# Canonical trigger: kill all six of the bosses below. When none are present,
# #Thylex_of_Veeshan spawns #Vulak`Aerr. Thylex itself is an invulnerable
# controller (special_abilities 19/20/24/25/35: immune to melee, magic, aggro,
# being aggro, and harm from clients) and is NOT part of the trigger - do not
# try to kill it.
#
# This script is intentionally instance-agnostic: it only uses zone-wide mob
# lookups, so it fires in the base zone (version 0) and in the Non-Respawning
# static instance (version 255 / template 0) alike.
#
# Diagnostics: the controller shouts (and logs via quest::debug) the list of
# guardians that still stand whenever that list changes, and GMs can say
# "status" to it for a private progress report.

my @bosses = (
  [124077, "Lady Mirenilla"],
  [124076, "Lady Nevederia"],
  [124008, "Lord Feshlak"],
  [124010, "Aaryonar"],
  [124074, "Lord Kreizenn"],
  [124017, "Lord Vyemm"],
);

sub remaining_bosses {
  my @up;
  foreach my $boss (@bosses) {
    my ($id, $name) = @$boss;
    push(@up, $name) if $entity_list->GetMobByNpcTypeID($id);
  }
  return @up;
}

sub vulak_is_up {
  return $entity_list->GetMobByNpcTypeID(124155);
}

sub remaining_count {
  my @remaining = remaining_bosses();
  return scalar(@remaining);
}

sub EVENT_SPAWN {
  my $count = remaining_count();
  $npc->SetEntityVariable("remaining_count", $count);
  quest::debug("Thylex controller online. Guardians standing: $count");
}

sub EVENT_SAY {
  return unless $client;
  return unless $client->GetGM() || $client->Admin() >= 80; # GM-only helper

  if ($text =~ /status|progress|vulak/i) {
    my @remaining = remaining_bosses();
    if (@remaining) {
      my $count = scalar(@remaining);
      $client->Message(14, "Vulak event: $count guardian(s) still stand: " . join(", ", @remaining) . ".");
      $client->Message(14, "Required set: Lady Mirenilla, Lady Nevederia, Lord Feshlak, Aaryonar, Lord Kreizenn, Lord Vyemm. (Lord Koi`Doken is not part of the trigger.)");
    } elsif (vulak_is_up()) {
      $client->Message(14, "Vulak event: all guardians are down and Vulak`Aerr is up.");
    } else {
      $client->Message(14, "Vulak event: all guardians are down but Vulak`Aerr is not spawned yet. Wait one tick, or confirm #Thylex_of_Veeshan is alive in this zone.");
    }
    return;
  }

  if ($text =~ /hail/i) {
    $client->Message(14, "Thylex event controller. Say 'status' for a progress report.");
  }
}

sub EVENT_TICK {
  my $count = remaining_count();
  my $last  = $npc->GetEntityVariable("remaining_count");
  $last = -1 unless defined($last) && $last =~ /^-?\d+$/;

  # All guardians are down: spawn Vulak`Aerr if he is not already in the zone.
  if ($count == 0) {
    if (!vulak_is_up()) {
      $npc->Shout("Intruders! Your doom is upon you! Vulak`Aerr comes to humble you, and return you to your pathetic Gods.");
      quest::spawn2(124155, 0, 0, -739.4, 517.2, 121, 510); # #Vulak`Aerr
      quest::debug("Thylex: all guardians down, spawned #Vulak`Aerr");
    }
    $npc->SetEntityVariable("remaining_count", 0);
    return;
  }

  # Report progress whenever the set of surviving guardians changes (a boss died).
  if ($count != $last) {
    my @remaining = remaining_bosses();
    my $list = join(", ", @remaining);
    $npc->Shout("Vulak`Aerr's awakening draws nearer. $count guardian(s) still stand: $list.");
    quest::debug("Thylex: $count guardian(s) remaining: $list");
    $npc->SetEntityVariable("remaining_count", $count);
  }
}

sub EVENT_DEATH_COMPLETE {
  # Only reachable via GM #damage; the controller is normally invulnerable.
  quest::debug("Thylex controller was destroyed - the Vulak event is now offline in this zone until it respawns.");
}

# EOF
