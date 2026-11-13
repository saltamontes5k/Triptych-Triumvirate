# Veeshan's Peak - "The Hoard Remembers" curio click-traps (migration v316)
# + "Throne of the First Brood" NetHack thrones (migration v331).
#
# ONLY the curio props and thrones react, nothing else in the zone:
#   - Phara Dar's hoard, the STOCK clickable props: doors 162-184 (VECOINS/
#     VEJEWL coin and jewel piles), 195-204 (VEBOX boxes), 205-206 (VEDRSTAT
#     dragon statues by the pit).
#   - Added lair props (v373): doors 1-6 = treasure piles (VECOINS101), 7-12
#     = dragon statues (VEDRSTAT101), one per lair.
#   - Throne triggers (v373): doors 13-18 (VEBRAZ101 royal braziers, one per
#     lair) and 19 = Phara Dar's Queen Throne (Vlad's Throne homage).
#   Door ids are a uint8; the old 601-630 rows truncated to 89-118 and aliased
#   stock doors, so they were retired and renumbered under 255.
# Treasure clicks roll the wide table; statues 50/50 guardians/paralyze;
# thrones roll the NetHack table (NO wishes - the throne only threatens).
# The stock Phara Dar seal (doors 56/57) below is untouched.
# Gate: Custom:CurioTraps; per-char 120s cooldown; GMs get the wink.

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

# lair anchors (x, y, floor z) - also the wrenching-teleport destinations
my @curio_lairs = (
  [-205.6, 1418.0, 445.0],   # Druushk
  [562.0, 1463.0, 260.0],    # Hoshkar
  [-560.8, 1170.6, 683.0],   # Nexona
  [-196.0, 320.0, 465.5],    # Silverwing
  [1208.9, 1336.4, 763.0],   # Xygoz
  [-1313.5, -1155.2, 280.5], # Phara Dar
);
my %curio_lair_of = (1=>0, 7=>0, 2=>1, 8=>1, 3=>2, 9=>2,
                     4=>3, 10=>3, 5=>4, 11=>4, 6=>5, 12=>5,
                     13=>0, 14=>1, 15=>2, 16=>3, 17=>4, 18=>5, 19=>5);

sub curio_click {
  # Guard: the whitelist IS the trap. Every other doorid in the zone falls
  # through untouched.
  my %is_treasure = map { $_ => 1 } (162..184, 195..204, 1..6);
  my %is_statue   = map { $_ => 1 } (205, 206, 7..12);
  my %is_throne   = map { $_ => 1 } (13..19);
  return unless ($is_treasure{$doorid} || $is_statue{$doorid} || $is_throne{$doorid});
  return if (quest::get_rule("Custom:CurioTraps") ne "true");
  if ($client->GetGM()) {
    $client->Message(15, "The hoard respects its makers. Door $doorid felt your touch and spared you.");
    return;
  }

  my $cd_key = "curio_cd_" . $client->CharacterID();
  if (quest::get_data($cd_key)) { return; }
  quest::set_data($cd_key, 1, 120);

  if ($is_throne{$doorid}) {
    &curio_throne();
    return;
  }

  # Statues: the brood answers, or everyone near you locks up. No mercy roll.
  if ($is_statue{$doorid}) {
    if (int(rand(100)) < 50) {
      quest::ze(15, "Cold eyes open in the stone. The hoard has wardens.");
      &curio_guardians($doorid);
    } else {
      &curio_paralyze();
    }
    return;
  }

  # Treasure piles.
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

# --- Throne of the First Brood (v331): the NetHack throne table, adapted ---
# 2/3 nothing ("out of place", or "very comfortable" once crowned), 1/3 one
# fate from the adapted table. NO wishes, NO genocide: the throne only ever
# threatens. Door 19 is the Queen Throne (Vlad's Throne homage) and skips
# straight to the curse table.
sub curio_throne {
  if ($doorid == 19) {
    &queen_throne();
    return;
  }

  my $crown_key = "curio_crowned_" . $client->CharacterID();
  my $crowned = quest::get_data($crown_key);

  # Base roll: 2/3 nothing.
  if (int(rand(3)) < 2) {
    if ($crowned) {
      $client->Message(15, "You feel very comfortable here.");
    } else {
      $client->Message(15, "You feel somehow out of place...");
    }
    return;
  }

  my $name = $client->GetName();
  my $roll = int(rand(12)); # 11 fates + the crowning
  if ($roll == 0) {
    # Insight: the one mercy.
    $client->Message(15, "You are granted an insight.");
    $client->SetMana($client->GetMaxMana());
  }
  elsif ($roll == 1) {
    # Much, much better.
    $client->Message(15, "You feel much, much better!");
    $client->SetHP($client->GetMaxHP());
  }
  elsif ($roll == 2) {
    # See invisible.
    $client->Message(15, "Your vision becomes clear.");
    $client->SpellFinished(80, $client);
  }
  elsif ($roll == 3) {
    # Attribute up: the First Brood approves of you, briefly.
    my @blessings = (3467, 173, 9466); # Virtue, Benevolence, Nimbus
    $client->Message(15, "The throne approves of you. For now.");
    $client->SpellFinished($blessings[int(rand(3))], $client);
  }
  elsif ($roll == 4) {
    # Tithe: flesh for the floor.
    my $dmg = int($client->GetMaxHP() * 0.15);
    quest::ze(15, "The throne takes its tithe from " . $name . ".");
    $client->Message(15, "The throne takes its tithe.");
    $client->SpellFinished(7536, $client);
    $client->Damage($client, $dmg, 0, 0, 0);
  }
  elsif ($roll == 5) {
    # Electric shock.
    quest::ze(15, "An electric shock shoots through " . $name . "'s body!");
    $client->Message(15, "An electric shock shoots through your body!");
    $client->SpellFinished(987, $client); # Spiroc Thunder
  }
  elsif ($roll == 6) {
    # Gold tithe: 10% of the purse, if there is a purse worth the trouble.
    my $purse = $client->GetPlatinum() * 1000 + $client->GetGold() * 100
              + $client->GetSilver() * 10 + $client->GetCopper();
    if ($purse >= 100000) {
      my $take = int($purse * 0.10);
      $client->TakeMoneyFromPP($take);
      quest::ze(15, "The throne tithes " . $name . "'s purse.");
      $client->Message(15, "The throne tithes your purse. It feels no gratitude.");
    } else {
      $client->Message(15, "You feel a strange sensation.");
    }
  }
  elsif ($roll == 7) {
    # Royal court summoned.
    quest::ze(15, "'Thy audience hath been summoned, Sire!'");
    $client->Message(15, "Thy audience hath been summoned, Sire!");
    &curio_guardians($doorid);
  }
  elsif ($roll == 8) {
    # Curse.
    quest::ze(15, "'A curse upon thee for sitting upon this most holy throne!'");
    $client->Message(15, "A curse upon thee for sitting upon this most holy throne!");
    $client->SpellFinished(7536, $client);
  }
  elsif ($roll == 9) {
    # Wrenching: the throne decides you sit elsewhere.
    $client->Message(15, "You feel a wrenching sensation.");
    my $own = $curio_lair_of{$doorid};
    my $dest = int(rand(6));
    $dest = int(rand(6)) while ($dest == $own);
    quest::movepc(108, $curio_lairs[$dest][0], $curio_lairs[$dest][1], $curio_lairs[$dest][2], 0);
  }
  elsif ($roll == 10) {
    # Pretzel.
    $client->Message(15, "Your mind turns into a pretzel!");
    $client->SpellFinished(8562, $client); # Vertigo
  }
  else {
    # Crowning: once.
    if ($crowned) {
      $client->Message(15, "You feel like a fraud.");
    } else {
      quest::set_data($crown_key, 1);
      quest::summonitem(4504); # Crown of King Tranix
      quest::ze(15, "The First Brood bows to " . $name . ". The throne room holds its breath.");
      $client->Message(15, "The First Brood bows to you. You are crowned, and the throne remembers.");
    }
  }
}

# --- The Queen Throne (door 19): Vlad's Throne homage. Pure curses; the ---
# Queen of the First Brood does not grant wishes to things that sit on her.
sub queen_throne {
  my $name = $client->GetName();
  my $roll = int(rand(6));
  if ($roll == 0) {
    # Level drain, EQ-style: the seat drinks you. Can hurt. Cannot kill by
    # itself at 30%, but it lands with the Lethargy rider.
    quest::ze(15, $name . " slumps on the Queen's throne. The stone drinks.");
    $client->Message(15, "You feel your strength flow into the stone. It was a bad experience sitting on a throne.");
    $client->SpellFinished(7536, $client);
    $client->Damage($client, int($client->GetMaxHP() * 0.30), 0, 0, 0);
  }
  elsif ($roll == 1) {
    # Grease.
    quest::ze(15, $name . " slides off the Queen's throne. Everything slips.");
    $client->Message(15, "Your fingers slip. Your boots slip. Everything slips.");
    $client->CastSpell(177, $client->GetID()); # Color Shift, freezes the court around you
  }
  elsif ($roll == 2) {
    # Acid drench. 'Killed by an acidic chair' is a real epitaph here.
    quest::ze(15, "The Queen's throne exhales acid over " . $name . ".");
    $client->Message(15, "You are drenched in acid. 'Killed by an acidic chair' would be an embarrassing epitaph.");
    $client->SpellFinished(1415, $client); # Torbas' Acid Blast
  }
  elsif ($roll == 3) {
    # The Queen's court answers.
    quest::ze(15, "The Queen's court answers " . $name . ". It is hungry.");
    $client->Message(15, "Thy audience hath been summoned, Sire. Her Majesty's court is hungry.");
    &curio_guardians(19);
  }
  elsif ($roll == 4) {
    # Random bless/curse.
    if (int(rand(2)) == 0) {
      $client->Message(15, "The throne grudgingly mends you. Do not tell anyone.");
      $client->SetHP($client->GetMaxHP());
    } else {
      quest::ze(15, "'A curse upon thee for sitting upon the Queen's throne!'");
      $client->Message(15, "A curse upon thee for sitting upon the Queen's throne!");
      $client->SpellFinished(7536, $client);
    }
  }
  else {
    # Forced teleport to another lair.
    $client->Message(15, "The Queen ejects you. You feel a wrenching sensation.");
    my $dest = int(rand(5)); # anywhere but her own lair (index 5)
    quest::movepc(108, $curio_lairs[$dest][0], $curio_lairs[$dest][1], $curio_lairs[$dest][2], 0);
  }
}

sub curio_guardians {
  my $trapped = shift;
  # the lair's own warden per trap door, plus a Guardian of Veeshan
  my %guard = (162=>108019, 163=>108019, 164=>108019, 165=>108019, 166=>108019,
               167=>108019, 168=>108019, 169=>108019, 170=>108019, 171=>108019,
               172=>108019, 173=>108019, 174=>108019, 175=>108019, 176=>108019,
               177=>108019, 178=>108019, 179=>108019, 180=>108019, 181=>108019,
               182=>108019, 183=>108019, 184=>108019,              # Phara Dar's hoard
               195=>108019, 196=>108019, 197=>108019, 198=>108019,
               199=>108019, 200=>108019, 201=>108019, 202=>108019,
               203=>108019, 204=>108019,                           # Phara Dar's boxes
               205=>108042, 206=>108042,                           # pit statues: Guardians of Veeshan
               1=>108016, 7=>108016,                               # Druushk
               2=>108017, 8=>108017,                               # Hoshkar
               3=>108018, 9=>108018,                               # Nexona
               4=>108042, 10=>108042,                              # Silverwing: two Guardians of Veeshan
               5=>108020, 11=>108020,                              # Xygoz
               6=>108019, 12=>108019,                              # Phara Dar
               13=>108016, 14=>108017, 15=>108018,                 # throne triggers (v373)
               16=>108042, 17=>108020, 18=>108019, 19=>108019);
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
