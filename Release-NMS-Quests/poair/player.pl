# Plane of Air - "The Hoard Remembers" curio click-traps (migration v316).
# ONLY our curio props react, nothing else in the zone:
#   - floating crystals: doors 601-608 (POTRANQROCK505, size 40) on the
#     doomseeker/Nilborien island clusters
#   - bookcases: doors 609-611 (POAFLYBK502, the flying book) - these really
#     do file you back to the Plane of Knowledge, landing in the library next
#     to Grand Librarian Maelin
# Deliberately NOT trapped (stock, load-bearing): door 1 = the Xegony rainbow
# (keyed, handled above), door 2 = the flying book EXIT porter to
# potranquility (dest_zone set - never trap a working exit), door 21 = the
# tranquility rock pad.
# Crystal clicks roll the terrible things: doomseeker adds, Color Cloud AOE
# paralyze, a buff wipe, the Drunken Stupor brew spell, or the divine rage of
# Xegony.
# Gate: Custom:CurioTraps; per-char 120s cooldown; GMs get the wink.

sub EVENT_CLICKDOOR {
  if($doorid == 1) {
    if($entity_list->FindDoor(1)->GetLockPick() != 0) {
      if(plugin::check_hasitem($client, 28638) || $client->KeyRingCheck(28638)) {
        $entity_list->FindDoor(1)->SetLockPick(0); #unlock the rainbow for 5 minutes
		    $entity_list->FindDoor(1)->SetKeyItem(0); #remove the key item so no one sees the message that door is locked.
        $client->KeyRingAdd(28638);
        quest::settimer("XegDoorOpen",300);
      }
    }
  }

  &curio_click($doorid);
}

sub EVENT_TIMER {
  if($timer eq "XegDoorOpen") {
    quest::stoptimer("XegDoorOpen");
	  $entity_list->FindDoor(1)->SetLockPick(-1); #lock the rainbow again
	  $entity_list->FindDoor(1)->SetKeyItem(28638); #put the key back on.
  }
}

sub curio_click {
  # Guard: the whitelist IS the trap. Doors 1, 2 and 21 (rainbow, exit book,
  # tranquility pad) are stock and never react here.
  return unless ($doorid >= 601 && $doorid <= 611);
  return if (quest::get_rule("Custom:CurioTraps") ne "true");
  if ($client->GetGM()) {
    $client->Message(15, "The hoard respects its makers. Door $doorid felt your touch and spared you.");
    return;
  }

  my $cd_key = "curio_cd_" . $client->CharacterID();
  if (quest::get_data($cd_key)) { return; }
  quest::set_data($cd_key, 1, 120);

  # Bookcases: the rumor, made true. Every single time.
  if ($doorid >= 609) {
    quest::ze(15, "The bookcase accepts " . $client->GetName() . ". Overdue.");
    $client->Message(15, "The bookcase swallows you whole and files you under 'Returned'.");
    quest::movepc(202, 1016, 16, 390.7, 130);
    return;
  }

  # Floating crystals (601-608).
  my $roll = int(rand(100));
  my $name = $client->GetName();
  if ($roll < 15) {
    quest::ze(15, "The crystal rings like a struck bell. Something answers.");
    &curio_doomseekers();
  }
  elsif ($roll < 30) {
    quest::ze(15, "The air tightens. Everything near " . $name . " locks up mid-step.");
    $client->CastSpell(7261, $client->GetID());
  }
  elsif ($roll < 45) {
    quest::ze(15, "The crystal drinks " . $name . "'s blessings like spilled wine.");
    $client->Message(15, "Your blessings unravel.");
    $client->BuffFadeAll();
  }
  elsif ($roll < 60) {
    quest::ze(15, $name . " takes a long pull of elemental vapor. It was not vapor.");
    $client->Message(15, "The sky distills. Your knees inform you that you are drunk.");
    $client->SpellFinished(7536, $client);
  }
  elsif ($roll < 85) {
    quest::ze(15, "The wind dies mid-scream. Xegony, Queen of Air, has seen what you touched.");
    $client->Message(15, "You have invoked the divine rage of Xegony.");
    $client->Damage($client, 1000000, 0, 0, 0);
  }
  else {
    $client->Message(15, "Nothing happens. This time.");
    quest::ze(15, "A coatl screams past like it is late for qualifying.");
  }
}

sub curio_doomseekers {
  my $x = $client->GetX();
  my $y = $client->GetY();
  my $z = $client->GetZ();
  foreach my $tid (215018, 215021) {
    next if $entity_list->IsMobSpawnedByNpcTypeID($tid);
    quest::spawn2($tid, 0, 0, $x + (10 - int(rand(20))), $y + (10 - int(rand(20))), $z, 0);
    my $npc = $entity_list->GetMobByNpcTypeID($tid);
    $npc->AddToHateList($client, 7500) if $npc;
  }
}
