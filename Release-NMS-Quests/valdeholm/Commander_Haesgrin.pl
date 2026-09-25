# Commander Haesgrin - Valdeholm (Frostcrypt raid 2 giver)
# Requests the Second Frostcrypt raid; requires the First Frostcrypt task.
# npc: 401039

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600006)) {
      quest::say("The First Frostcrypt still stands, $name. Break Hearol and Griswald before you seek me out.");
    }
    elsif (!quest::istaskcompleted(600007)) {
      quest::say("You have done what few could, $name. But the crypts run deeper. Will you [" . quest::saylink("continue") . "]?");
    }
    else {
      quest::say("The Sleepless Guard is broken and the Shade King fallen. Valdeholm owes you everything, $name.");
    }
  }

  if ($text=~/continue/i) {
    if (!quest::istaskcompleted(600006)) {
      quest::say("First prove yourself in the First Frostcrypt, $name.");
    }
    elsif (!quest::istaskactive(600007) && !quest::istaskcompleted(600007)) {
      quest::say("Then we go deeper. Wulfnor, Fridleif, Harfange, and Beltron himself still hold the crypts. Seek Sergeant Thavin and tell him [" . quest::saylink("Haesgrin sent me") . "].");
      quest::assigntask(600007);
      $client->CreateExpeditionFromTemplate(6012);
    }
    else {
      quest::say("The crypts wait. Tell Sergeant Thavin [" . quest::saylink("Haesgrin sent me") . "] and finish what we started.");
      $client->CreateExpeditionFromTemplate(6012);
    }
  }
}
