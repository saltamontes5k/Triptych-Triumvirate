# Gekkdar the Last Ogre Chief - Crescent Reach (The Hollow catacombs)
# The Serpent's Spine :: Akins #2 - Bump in the Night: The Ogre's Spirit

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Who is it that disturbs my slumber? Unless you are the [" . quest::saylink("one") . "], begone from this place of chiefs!");
  }
  if ($text=~/the one/i) {
    quest::say("Only a true heir of the Rockjaws or Thoots can [" . quest::saylink("free") . "] me from my torment. As long as the Amulet of Chieftains is mine, here I will remain. I wait for the day that the heir comes to this place.");
  }
  if ($text=~/free/i) {
    quest::say("Ancient magic binds me to this place. The magic of the Amulet of Chieftains must be passed from one Chief to the next. Only a true heir may take the Amulet. All others who touch it will surely die. Alas, I died alone with no heir and am consigned to wait here. Now go, or I shall rouse myself and you will feel my [" . quest::saylink("wrath") . "]!");
  }
  if ($text=~/wrath/i) {
    quest::say("Do not tempt your fate, little one! My patience with you is at an end. Go now or [" . quest::saylink("die") . "]!");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
