# Hranath Velentok - Sunderock Springs
# The Serpent's Spine :: Unearthed Power (task 600219)
# Item: Flawless Indicolite Shard 87246, reward Flute of Draconic Dazzling 53656

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Gah! I can barely think as it is and now you come bothering me? If it weren't for the [" . quest::saylink("influence") . "] of these ruins I might actually get some work done.");
  }
  if ($text=~/influence/i) {
    quest::say("What influence you ask? I can feel something ancient and powerful radiating from beneath the mines. The forces there have finished searching the entry halls and resumed mining, but there are [" . quest::saylink("artifacts") . "] deeper in.");
  }
  if ($text=~/artifacts/i) {
    if (!quest::istaskactive(600219) && !quest::istaskcompleted(600219)) {
      quest::say("The power seems bound to an unearthed orb in the Vergalid Mines. Destroy it and bring me a Flawless Indicolite Shard, and I will make it worth your while.");
      quest::assigntask(600219);
    }
    else {
      quest::say("The unearthed orb still pulses beneath Vergalid. Bring me its shard.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
