# Scout Zryan - Direwind Cliffs
# The Serpent's Spine :: Zryan #1 (The Gray Legion, 600120) and #2 (The Approach, 600121)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600120)) {
      quest::say("Hail, $name. I am Zryan, son of Captain Zheren. The Gray Legion holds the ground south-east of here. While outnumbered, the superior warrior stalks with patience and strikes only when the time is right. Will you help me break them?");
    }
    elsif (!quest::istaskcompleted(600121)) {
      quest::say("Well done. You are now ready for the main attack on the [approach].");
    }
    else {
      quest::say("With the seals in hand, the statue guardians outside Ashengate will let you pass. My father will be most impressed.");
    }
  }
  if ($text=~/gray legion/i && !quest::istaskactive(600120) && !quest::istaskcompleted(600120)) {
    quest::say("Kill their soldiers, clerics, mages, and sergeants, and bring me Orzhok's Shattered Shield as proof. They camp just south-east of here.");
    quest::assigntask(600120);
  }
  if ($text=~/approach/i && quest::istaskcompleted(600120) && !quest::istaskactive(600121) && !quest::istaskcompleted(600121)) {
    quest::say("When outnumbered, the superior warrior stalks with patience. Recover the seals of the northern outposts and the Ashengate Seal, and I can get you past the statue guardians.");
    quest::assigntask(600121);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
