# Scout Zryan - Direwind Cliffs
# The Serpent's Spine :: Zryan arc (raspersrealm open_Direwind):
#   600120 #1 The Gray Legion, 600121 #2 The Approach,
#   600122 #3 The Ashengate Griffins (via Scout Keshik),
#   600123 #4 The Black Legion, 600124 #5 Report from the Front Lines.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600120)) {
      quest::say("Hail, $name. I am Zryan, son of Captain Zheren. The Gray Legion holds the ground south-east of here. While outnumbered, the superior warrior stalks with patience and strikes only when the time is right. Will you help me break them?");
    }
    elsif (!quest::istaskcompleted(600121)) {
      quest::say("Well done. You are now ready for the main attack on the [approach].");
    }
    elsif (!quest::istaskcompleted(600122)) {
      quest::say("The statue guardians will let you pass now -- but the climb wastes the day. My scout [Keshik] runs griffons below the gate. She will get you [airborne].");
    }
    elsif (!quest::istaskcompleted(600123)) {
      quest::say("With the gate behind us, the Black Legion is next. Their camp crawls with couriers carrying Dyn`leth's [plans].");
    }
    elsif (!quest::istaskcompleted(600124)) {
      quest::say("Take word of our success to my father. He commands the forward camp in [Sunderock Springs]. Tell him his son sends [reports] worthy of the Crusade.");
    }
    else {
      quest::say("The road to Ashengate stands open because of you, $name. The Crusade of the Scale will remember.");
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
  if ($text=~/keshik/i || $text=~/airborne/i) {
    if (quest::istaskcompleted(600121) && !quest::istaskactive(600122) && !quest::istaskcompleted(600122)) {
      quest::say("She will want you bonded to the flock before they fly you. See her at the aviary and mind the beaks.");
      quest::assigntask(600122);
    }
    else {
      quest::say("Her aviary sits below the Ashengate gate.");
    }
  }
  if ($text=~/plans/i) {
    if (quest::istaskcompleted(600122) && !quest::istaskactive(600123) && !quest::istaskcompleted(600123)) {
      quest::say("Cut down the legionnaires until the battle plans surface, then bring them to me. Dyn`leth's own hand is on them.");
      quest::assigntask(600123);
    }
  }
  if ($text=~/reports/i || $text=~/Sunderock Springs/i) {
    if (quest::istaskcompleted(600123) && !quest::istaskactive(600124) && !quest::istaskcompleted(600124)) {
      quest::say("Here is my report. He will be proud -- or he will find more work for you. Either way, the Crusade advances.");
      quest::assigntask(600124);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
