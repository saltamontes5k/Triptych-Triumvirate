# Kluno Orenbrew - Direwind Cliffs
# The Serpent's Spine :: Finding Felena #2 delivery (600411) and #3 giver (600412).
# Located at -960, -670 in the Direwind Cliffs.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600410)) {
      quest::say("Oi. Kluno trades in information, not gossip. Come back when you have coin or [goods].");
    }
    elsif (!quest::istaskactive(600411) && !quest::istaskcompleted(600411)) {
      quest::say("A letter from Maven, is it? Hmph. Her girl passed through, sure enough -- headed for the [mines], if my mark is right. But my mark costs.");
    }
    elsif (quest::istaskactive(600411)) {
      quest::say("The samples, $name. Magnesium from the western ledges, sulphur compound, a soil sample, and a darksoot mushroom from the caves. Bring all four and my mark is yours.");
    }
    elsif (!quest::istaskcompleted(600412)) {
      quest::say("My mark points one way: the Vergalid [mines]. Rozoth Orbu keeps a tent there -- he will not cut your throat, whatever the rest of his kin might say.");
    }
    elsif (!quest::istaskcompleted(600413)) {
      quest::say("The [mines], I said. Rozoth will know what the trail means.");
    }
    else {
      quest::say("The Bellstone girl home safe? Good. Kluno's mark never lies.");
    }
  }

  if ($text=~/goods/i) {
    quest::say("Minerals, soil, mushrooms. The deep places of this zone hold all manner of curious [goods].");
  }

  if ($text=~/mines/i) {
    if (quest::istaskcompleted(600411) && !quest::istaskactive(600412) && !quest::istaskcompleted(600412)) {
      quest::say("Find Rozoth and show him the trail. If anything of the girl remains in those tunnels, he will know it.");
      quest::assigntask(600412);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
