# Zhubis the Griffon Tamer - Direwind Cliffs
# The Serpent's Spine :: Ashengate access (The Pretender, task 600022)
# Located at +960, -1045 in Direwind (south of Gatekeeper Kor, across the valley).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600022)) {
      quest::say("Do not draw attention to me, $name. I was born into a world for someone else's cause, meant to die for someone else's flawed beliefs. Though this has afforded me some interesting [" . quest::saylink("information") . "] that I could share.");
    }
    else {
      quest::say("What you have done cannot be undone. Say nothing of me.");
    }
  }

  if ($text=~/information/i) {
    quest::say("The one who has been whispering into Dyn`leth's ear is no true believer. Find Nurtha Frazzlesprocket within the Vergalid Mines and learn the truth from her. Then deal with her before she deals with you.");
    if (!quest::istaskactive(600022) && !quest::istaskcompleted(600022)) {
      quest::assigntask(600022);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
