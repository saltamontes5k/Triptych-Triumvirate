# Syrrengar the Hunter - Sunderock Springs
# The Serpent's Spine :: Beasts of Sunderock (600424), Beasts of Direwind (600425)
# Both tasks are independent, offered together, and require level 65.
# Trophy items are pre-lootable; the loot steps credit from inventory.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("Come back when you are stronger, $name. These are no beasts for the untested.");
      return;
    }
    quest::say("I hunt the great beasts of the valley and the cliffs beyond. Which trail will you walk, the [" .
               quest::saylink("Sunderock") . "] or the [" . quest::saylink("Direwind") . "]?");
  }

  if ($text=~/sunderock/i) {
    if ($client->GetLevel() < 65) {
      quest::say("Not yet, $name.");
      return;
    }
    if (quest::istaskactive(600424)) {
      quest::say("Bring me Komodokin's claw, Sandstorm's fin, Skyrake's horn, Tortugone's shell spike, and Trideath's mane.");
    }
    else {
      quest::say("Five beasts stalk Sunderock: Komodokin, Sandstorm, Skyrake, Tortugone, and Trideath. Bring me a trophy from each.");
      quest::assigntask(600424);
    }
  }

  if ($text=~/direwind/i) {
    if ($client->GetLevel() < 65) {
      quest::say("Not yet, $name.");
      return;
    }
    if (quest::istaskactive(600425)) {
      quest::say("Bring me Darkenfin's spine, Ezak's fang, Ghostfeather's talon, Koda's paw, and Shadowpaw's claw.");
    }
    else {
      quest::say("Five beasts prowl the cliffs: Darkenfin, Denlord Ezak, Ghostfeather, Koda, and Shadowpaw. Bring me a trophy from each.");
      quest::assigntask(600425);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# The page states the beast trophies can be pre-looted; EQEmu loot activities
# only credit on the loot event, so scan the player's bags on accept.
sub EVENT_TASKACCEPTED {
  return unless defined($task_id);
  if ($task_id == 600424) {
    my @parts = (85712, 85725, 85711, 85713, 85710);
    for (my $i = 0; $i < @parts; $i++) {
      quest::updatetaskactivity(600424, $i, 1) if quest::countitem($parts[$i]) > 0;
    }
  }
  elsif ($task_id == 600425) {
    my @parts = (85726, 85674, 85673, 85671, 85672);
    for (my $i = 0; $i < @parts; $i++) {
      quest::updatetaskactivity(600425, $i, 1) if quest::countitem($parts[$i]) > 0;
    }
  }
}
