# Herald Nexeu - Crescent Reach
# The Serpent's Spine :: Love in the Air #2 (task 600091)
# Item: Amulet of Desire 85090

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hail and well met! I am Herald Nexeu, voice of the city. Do you need an announcement?");
  }
  if ($text=~/fun/i) {
    quest::say("Well, it makes more sense for me to give an amulet with my likeness on it to someone I have eyes for, no? Indeed. Give this amulet that Kamilah intended for me to the fairest drakkin of all - [" . quest::saylink("Moswen") . "]. She works in Artisan's Row.");
    if (!quest::istaskactive(600092) && !quest::istaskcompleted(600092)) {
      quest::assigntask(600092);
    }
  }
  if ($text=~/Moswen/i) {
    quest::say("Aye, Moswen. Fair as a summer morning. Give her the amulet and tell her it's from me. She'll come around.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85090 => 1)) { #Amulet of Desire
    quest::say("For crying out loud! Why on earth would I wear an amulet that had my face on it? That Kamilah is out of her mind. Just the other day she interrupted my heralding practice by offering me a rat cake. A rat cake! Clearly we could never be matched. I do seek a match, though. If you're interested in a bit of [" . quest::saylink("fun") . "], come see me.");
    quest::emote("shakes his head and hands the amulet back to you before catching himself and letting you keep it.");
  }
  plugin::return_items(\%itemcount);
}
