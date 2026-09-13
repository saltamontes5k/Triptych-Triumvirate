# Nettle Higglesbury - Misty Thicket
# The Serpent's Spine :: Peace and Understanding - Quellious' Favor (task 600220)
# A halfling caught in the Fordel / Midst feud.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Oh! You startled me. I'm Nettle. This whole thicket's gone mad - the Fordel on one side, the Midst on the other, and me stuck in the middle. They slink in at night and ruin my crops!");
  }
  if ($text=~/Fordel/i || $text=~/Midst/i) {
    quest::say("They accuse each other of everything! 'Fordel, stop taking all the village idiots!' 'Quit sending your people over here then!' It never ends. If only someone could calm them down.");
  }
  if ($text=~/calm/i) {
    quest::say("The Tranquil, Quellious, is the only one who could. Her Avatar walks the Plane of Tranquility. Perhaps an outsider like you could ask for her favor.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
