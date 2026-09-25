# Maven Bellstone - Direwind Cliffs
# The Serpent's Spine :: Finding Felena arc (600410-600413).
# Maven gives #1 (Vonsolu's note) and #2 (Kluno's samples); Kluno gives #3;
# Rozoth Orbu (Vergalid) gives #4. Reward choice on 600413:
# Mantle of Spirits / Cloak of the Winterwinds / Bronzefire Earring.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600410)) {
      quest::say("Please, traveler -- have you seen a young dwarven woman pass through? My [daughter] Felena. She left to see the Steppes and no word has come back.");
    }
    elsif (!quest::istaskcompleted(600411)) {
      quest::say("A note from Captain Vonsolu... so she did pass this way. Kluno Orenbrew tracks travelers for coin -- perhaps he has [seen] something.");
    }
    elsif (!quest::istaskcompleted(600412)) {
      quest::say("Kluno says the trail leads into the Vergalid [mines]. Find his contact there, Rozoth Orbu.");
    }
    elsif (!quest::istaskcompleted(600413)) {
      quest::say("Rozoth's word is grim, but my Felena lives. Bring her home, $name.");
    }
    else {
      quest::say("My daughter is home, and it is your doing. The Bellstones will not forget you, $name.");
    }
  }

  if ($text=~/daughter/i) {
    quest::say("She is headstrong, like her father. She went looking for adventure in the [Steppes], and I fear she found it.");
  }

  if ($text=~/Steppes/i || $text=~/seen/i) {
    if (!quest::istaskactive(600410) && !quest::istaskcompleted(600410)) {
      quest::say("A hunter named Vonsolu was slain in the Steppes not long ago. Look near his body, west of the great camps, for any [note] he left.");
      quest::assigntask(600410);
    }
    elsif (quest::istaskcompleted(600410) && !quest::istaskactive(600411) && !quest::istaskcompleted(600411)) {
      quest::say("Take this letter to Kluno Orenbrew. He asks strange payment -- soil and stone -- but he knows the cliffs better than anyone.");
      quest::assigntask(600411);
      quest::summonitem(87182);
    }
  }

  if ($text=~/note/i) {
    quest::say("Anything at all. Please hurry, $name.");
  }

  if ($text=~/mines/i) {
    quest::say("Rozoth Orbu keeps a tent there. The other drakkin are dangerous -- mind yourself.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
