# Atler Flamejabber - West Freeport (blessing task 700181, Quellious' Favor)
# The blessing-side twin of the Crescent Reach original (task 600220); hail only.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Beautiful, isn't it? I don't get out much, but when I do, I try to mend what's broken. The [" . quest::saylink("quarrel") . "] between the Fordel and the Midst is one I cannot mend alone.");
  }
  if ($text=~/quarrel/i) {
    quest::say("They make war with words - and worse. Only the Tranquil can show them peace. The Avatar of Quellious waits in the Plane of Tranquility, and her wand will quiet the loudest of them. Go with patience, $name.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
