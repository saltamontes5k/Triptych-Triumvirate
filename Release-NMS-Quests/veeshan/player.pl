# Veeshan's Peak - "The Hoard Remembers" curio click-traps (migration v316).
# Invisible OBJ_CURIO_TRAP trigger doors sit on the lair treasure piles
# (601,603,605,607,609,611) and the statue/bookcase props (602,604,606,608,
# 610,612). Touching them rolls: mailed-to-poair, the Drunken Stupor brew
# spell, a buff wipe, guardian adds, a Color Cloud AOE paralyze that freezes
# everyone near the clicker, or Veeshan herself answering the theft. The
# stock Phara Dar seal (doors 56/57) below is untouched.
# Gate: Custom:CurioTraps; per-char 120s cooldown; GMs are spared.

sub EVENT_CLICKDOOR {
  my $dragonsup = 0;
  if ($entity_list->IsMobSpawnedByNpcTypeID(108053)) { #Xygoz
    $dragonsup++;
  }
  if ($entity_list->IsMobSpawnedByNpcTypeID(108040)) { #Druushk
    $dragonsup++;
  }
  if ($entity_list->IsMobSpawnedByNpcTypeID(108047)) { #Nexona
    $dragonsup++;
  }
  if ($entity_list->IsMobSpawnedByNpcTypeID(108043)) { #Hoshkar
    $dragonsup++;
  }
  if ($entity_list->IsMobSpawnedByNpcTypeID(108050)) { #Silverwing
    $dragonsup++;
  }
  if ($doorid == 56 || $doorid == 57) {
    if ($dragonsup == 0) {
      $client->Message(0,"You got the door open.");
      quest::forcedooropen(56);
      quest::forcedooropen(57);
    }
    else {
      $client->Message(0,"A seal has been placed on this door by Phara Dar. Perhaps there is a way to remove it.");
    }
  }

  &curio_click($doorid);
}

sub curio_click {
  return if ($doorid < 601 || $doorid > 612);
  return if (quest::get_rule("Custom:CurioTraps") ne "true");
  if ($client->GetGM()) {
    $client->Message(15, "The hoard respects its makers. Door $doorid felt your touch and spared you.");
    return;
  }

  my $cd_key = "curio_cd_" . $client->CharacterID();
  if (quest::get_data($cd_key)) { return; }
  quest::set_data($cd_key, 1, 120);

  # Statues and bookcases (even doorids): the brood answers, or everyone near
  # you locks up. No mercy roll.
  if ($doorid % 2 == 0) {
    if (int(rand(100)) < 50) {
      quest::ze(15, "Cold eyes open in the stone. The hoard has wardens.");
      &curio_guardians($doorid);
    } else {
      &curio_paralyze();
    }
    return;
  }

  # Treasure piles (odd doorids).
  my $roll = int(rand(100));
  my $name = $client->GetName();
  if ($roll < 20) {
    quest::ze(15, $name . " is mailed to the Plane of Air. Postage due.");
    $client->Message(15, "You are mailed to the Plane of Air. Postage due.");
    quest::movepc(215, 884, 532, -90, 0);
  }
  elsif ($roll < 40) {
    quest::ze(15, $name . " takes a celebratory swig from the hoard's flask. It was not celebratory.");
    $client->Message(15, "The vault tastes you back. Your knees inform you that you are drunk.");
    $client->SpellFinished(7536, $client);
  }
  elsif ($roll < 55) {
    quest::ze(15, "The hoard breathes out, and " . $name . "'s blessings unravel like cheap guild-bank thread.");
    $client->Message(15, "Your blessings unravel.");
    $client->BuffFadeAll();
  }
  elsif ($roll < 70) {
    quest::ze(15, "The treasure shifts. Claws scrape against coin.");
    &curio_guardians($doorid);
  }
  elsif ($roll < 80) {
    &curio_paralyze();
  }
  elsif ($roll < 90) {
    quest::ze(15, "A voice like splitting mountains rolls across the peaks: 'WHO TOUCHES THE HOARD OF THE FIRST BROOD?'");
    $client->Message(15, "Veeshan's wrath finds you. You should have listened.");
    $client->Damage($client, 1000000, 0, 0, 0);
  }
  else {
    $client->Message(15, "Nothing happens. This time.");
    quest::ze(15, "A coin clinks softly somewhere near " . $name . ".");
  }
}

sub curio_guardians {
  my $trapped = shift;
  # the lair's own warden per trap door, plus a Guardian of Veeshan
  my %guard = (601=>108016, 602=>108016,  # Druushk
               603=>108017, 604=>108017,  # Hoshkar
               605=>108018, 606=>108018,  # Nexona
               607=>108042, 608=>108042,  # Silverwing: two Guardians of Veeshan
               609=>108020, 610=>108020,  # Xygoz
               611=>108019, 612=>108019); # Phara Dar
  my $lair = $guard{$trapped};
  return unless $lair;
  my $x = $client->GetX();
  my $y = $client->GetY();
  my $z = $client->GetZ();
  foreach my $tid ($lair, 108042) {
    next if $entity_list->IsMobSpawnedByNpcTypeID($tid);
    quest::spawn2($tid, 0, 0, $x + (10 - int(rand(20))), $y + (10 - int(rand(20))), $z, 0);
    my $npc = $entity_list->GetMobByNpcTypeID($tid);
    $npc->AddToHateList($client, 7500) if $npc;
  }
}

sub curio_paralyze {
  quest::ze(15, "The hoard exhales. Everything near " . $client->GetName() . " locks up mid-step.");
  $client->CastSpell(7261, $client->GetID());
}
