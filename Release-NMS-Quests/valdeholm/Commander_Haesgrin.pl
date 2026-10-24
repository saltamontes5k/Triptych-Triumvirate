# Commander Haesgrin - Valdeholm (Frostcrypt raid 2 giver)
# Also: Weapons Acquisition (600722), Shade Bounty (600725), Incursion (600729)
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

  if ($text=~/weapons/i) {
    if (!quest::istaskactive(600722) && !quest::istaskcompleted(600722)) {
      quest::say("We lack steel of our own making. Bring me shadow forged weapons from the crypts of Frostcrypt - blades, axes, hammers, four of each.");
      quest::assigntask(600722);
    }
    else {
      quest::say("Four shadow forged blades, axes, and hammers. The crypts hold plenty.");
    }
  }
  if ($text=~/hunting/i) {
    if (!quest::istaskactive(600725) && !quest::istaskcompleted(600725)) {
      quest::say("The shades carry marks of their master. Four marks bounty, paid on delivery.");
      quest::assigntask(600725);
    }
    else {
      quest::say("Four marks of Rallos Zek from the Frostcrypt shades.");
    }
  }
  if ($text=~/reports/i) {
    if (!quest::istaskactive(600729) && !quest::istaskcompleted(600729)) {
      quest::say("The incursion grows bolder. Cut down the soldiers of Zek in Frostcrypt - fifteen of them - and the forward line holds for another week.");
      quest::assigntask(600729);
    }
    else {
      quest::say("Fifteen soldiers of Zek in Frostcrypt. That is the report I need.");
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
