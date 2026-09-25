# Rozoth Orbu - Vergalid Mines
# The Serpent's Spine :: Finding Felena #3 delivery (600412) and #4 giver (600413).
# Located in a tent in the Vergalid Mines. Non-KOS unlike the other drakkin here.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600411)) {
      quest::say("Keep your distance. I have no quarrel with you, but my kin here cannot say the same.");
    }
    elsif (!quest::istaskactive(600412) && !quest::istaskcompleted(600412)) {
      quest::say("Kluno's mark... you seek a dwarf girl, then. She was dragged through here toward the [deep chambers]. I kept... a piece of cloth that caught on the stones. Proof she came this way.");
    }
    elsif (quest::istaskactive(600412)) {
      quest::say("The garment. Ripped from the rares that haunt these mines -- the trilobites in the far north chamber, the overseers. Bring it to me.");
    }
    elsif (!quest::istaskcompleted(600413)) {
      quest::say("The trail ends in the Steppes, in the far northern caves. Commander Drenkith Zon`Tak keeps her. Tell him: [I am here to free Felena]. Then end him.");
    }
    else {
      quest::say("She is safe, and Drenkith is dust. Well done, softskin.");
    }
  }

  if ($text=~/deep chambers/i) {
    quest::say("Down, past the egg chambers and the shrine. Careless things drop bits of their [prey] all through the mines.");
  }

  if ($text=~/prey/i) {
    quest::say("Go. Find the [garment] and bring it to me, and I will tell you who took her.");
  }

  if ($text=~/garment/i) {
    if (quest::istaskactive(600412) && !quest::istaskcompleted(600412)) {
      quest::say("Bring me the torn garment, $name.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
