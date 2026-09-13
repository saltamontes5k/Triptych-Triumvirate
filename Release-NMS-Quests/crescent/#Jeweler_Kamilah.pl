# Jeweler Kamilah - Crescent Reach
# The Serpent's Spine :: Love in the Air #1/#2 (tasks 600090, 600091)
# Items: Wild Crescent Rose 85089, Amulet of Desire 85090

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Welcome to my shop, $name. Fine jewelry, made with care. Is there something you fancy?");
  }
  if ($text=~/drakkin/i) {
    quest::say("Oh, a gift? Forgive me. The one I wish would show some interest never notices me... and believe me, I do try. You seem willing to help make a match. Would you deliver this amulet to Herald Nexeu for me? I created it with his likeness.");
    if (!quest::istaskactive(600091) && !quest::istaskcompleted(600091)) {
      quest::say("Take it to him, and tell him it is from me.");
      quest::summonitem(85090); # Amulet of Desire
      quest::assigntask(600091);
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85089 => 1)) { #Wild Crescent Rose
    quest::say("A gift? For me? And from whom - oh! From Minka? That dear, dear man. Tell him I said thank you. And that I noticed.");
    quest::emote("blushes as she tucks the rose into her hair.");
  }
  plugin::return_items(\%itemcount);
}
