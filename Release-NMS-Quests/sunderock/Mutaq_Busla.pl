# Mutaq Busla - Sunderock Springs
# The Serpent's Spine :: Kill the Miners (600433)
# Clear the Kickpick and Skullcrush miners at the Vergalid entrance.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("You look green, $name. Come back with some scars.");
      return;
    }
    if (quest::istaskactive(600433)) {
      quest::say("Twenty of them, $name. Kickpick or Skullcrush, I don't care which.");
    }
    else {
      quest::say("Those miners march out of Vergalid like they own the valley. Thin the [" . quest::saylink("herd") .
                 "], twenty of them, and I will make it worth your while.");
    }
  }

  if ($text=~/herd/i && $client->GetLevel() >= 65 && !quest::istaskactive(600433)) {
    quest::assigntask(600433);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
