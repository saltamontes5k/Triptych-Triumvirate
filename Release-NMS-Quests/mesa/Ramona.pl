# Ramona - Goru`kar Mesa
# The Serpent's Spine :: alchemist; cure-components hand-in for
# Save the Queen #4 (task 600625).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600625)) {
      quest::say("Puma paw, recluse venom, snake fang - my mortar waits. Ekaterina's poor queen has no time to spare.");
    }
    elsif (quest::istaskcompleted(600626)) {
      quest::say("The antidote did what antidotes do, or it did not. Either way, the brewing was honest.");
    }
    else {
      quest::say("Bring me teeth and claws and I will bring you chemistry, traveler.");
    }
  }
}

sub EVENT_ITEM {
  # Consume the cure components only while task 600625 is active (task
  # system handles completion); anything else is returned.
  if (quest::istaskactive(600625)) {
    plugin::check_handin(\%itemcount, 92816 => 1, 87177 => 1, 13067 => 1);
  }
  plugin::return_items(\%itemcount);
}
