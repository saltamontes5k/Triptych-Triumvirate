# Plane of Air - "The Hoard Remembers" curio click-traps (v372: objects).
#
# The door route is retired. The client/server door id is a uint8, PoA has 309
# named props but only 251 free door ids, so the old 601-909 door rows could
# never load as themselves. Every named prop now has a duplicate OBJECT at its
# exact WLD placement (migration v372, object type CurioTrigger), and clicking
# it raises EVENT_CLICK_OBJECT. The duplicate is invisible because it shares
# the prop's model, position, heading and scale.
#
# Crystals, goblets and scrolls roll the terrible-things table. Bookcases and
# flying books file you into the Plane of Knowledge library (the rumour, made
# true). Stock door 1 (the keyed rainbow), 2 (the potranquility exit book) and
# 21 (the tranquility pad) are untouched.
#
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
}

sub EVENT_TIMER {
  if($timer eq "XegDoorOpen") {
    quest::stoptimer("XegDoorOpen");
    $entity_list->FindDoor(1)->SetLockPick(-1); #lock the rainbow again
    $entity_list->FindDoor(1)->SetKeyItem(28638); #put the key back on.
  }
}

sub EVENT_CLICK_OBJECT {
  return unless $object;

  my $model = $object->GetModelName();
  if ($client->GetGM()) {
    $client->Message(15, "Curio object hit: " . $model);
  }
  return unless $model =~ /^POA(?:CRYS|GBLT|SCROLL|BKSHF|FLYBK)/;

  my $dx = $client->GetX() - $object->GetX();
  my $dy = $client->GetY() - $object->GetY();
  my $dz = $client->GetZ() - $object->GetZ();
  return if (($dx * $dx + $dy * $dy + $dz * $dz) > 3600); # 60 units

  return if &curio_poa_guard();

  if ($model =~ /^POA(?:BKSHF|FLYBK)/) {
    &curio_poa_book();
  }
  else {
    &curio_poa_crystal();
  }
}

sub curio_poa_guard {
  return 1 if (quest::get_rule("Custom:CurioTraps") ne "true");

  if ($client->GetGM()) {
    $client->Message(15, "The hoard respects its makers. This curio felt your touch and spared you.");
    return 1;
  }

  my $cd_key = "curio_cd_" . $client->CharacterID();
  return 1 if (quest::get_data($cd_key));
  quest::set_data($cd_key, 1, 120);
  return 0;
}

sub curio_poa_book {
  quest::ze(15, "The bookcase accepts " . $client->GetName() . ". Overdue.");
  $client->Message(15, "The bookcase swallows you whole and files you under 'Returned'.");
  quest::movepc(202, 1016, 16, 390.7, 130);
}

sub curio_poa_crystal {
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
