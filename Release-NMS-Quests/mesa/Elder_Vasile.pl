# Elder Vasile - Goru`kar Mesa
# The Serpent's Spine :: satyr elder tasks (tasks 600648-600649).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600648)) {
      quest::say("The [roost] entry lies east of here. Walk it and come back to me.");
    }
    elsif (quest::istaskactive(600649)) {
      quest::say("[Ten] guards, traveler. They mass before we are ready.");
    }
    elsif (!quest::istaskcompleted(600648)) {
      quest::say("My son has not come home, and my heart grows [cold]. Will you walk for me?");
    }
    elsif (!quest::istaskcompleted(600649)) {
      quest::say("So the roost holds him yet. Then hold this: [they] are coming, and we must be ready.");
    }
    else {
      quest::say("You gave an old satyr hope twice over, $name. That is no small thing.");
    }
  }
  if ($text=~/cold/i && !quest::istaskactive(600648) && !quest::istaskcompleted(600648)) {
    quest::say("Explore the entry to Blackfeather Roost, east of our camp, then return and tell me what the wind says of him.");
    quest::assigntask(600648);
  }
  if ($text=~/they/i && quest::istaskcompleted(600648) && !quest::istaskactive(600649) && !quest::istaskcompleted(600649)) {
    quest::say("Tuffein guards, ten at least, probing our borders. Slay them and send the rest a message they will feel.");
    quest::assigntask(600649);
  }
  if ($text=~/roost/i && quest::istaskactive(600648)) {
    quest::say("East, where the harpies wheel. Mind the sky, traveler.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
