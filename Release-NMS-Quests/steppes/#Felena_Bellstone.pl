# Felena Bellstone - The Steppes (Drenkith's cave)
# The Serpent's Spine :: Finding Felena #4 (600413) final hail.
# Located behind Commander Drenkith Zon`Tak in the far northern cave.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600413)) {
      quest::say("You... you came for me? Drenkith is dead? Blessed Brell -- my father must be beside himself. Let us go home, $name.");
    }
    elsif (quest::istaskcompleted(600413)) {
      quest::say("Father has not stopped boasting about you, $name. Thank you again.");
    }
    else {
      quest::say("Please... if you have come to help, the commander will not part with me willingly. He listens for his [name].");
    }
  }
  if ($text=~/name/i) {
    quest::say("Drenkith. Tell him who you have come for, and his rage will do the rest.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
