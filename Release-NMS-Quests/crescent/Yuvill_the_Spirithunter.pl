# Yuvill the Spirithunter - Crescent Reach (third level of the city)
# The Serpent's Spine :: Heshyrr's Wisdom (task 600242), step 3.
# Live, Yuvill is invisible and only Heshyrr's Seeker's Spiritstaff (84221)
# reveals him; here the step is gated on carrying the staff.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600242, 2)) {
      if ($client->CountItem(84221)) { # Seeker's Spiritstaff
        quest::emote("fades into view, eyes silver as moonlight.");
        quest::say("So. The staff of my teacher's first-born, warm in a living hand. You want the tale, then? Sit. Long before the drakkin, this city was Nokk, greatest of the ogre cities. Its stone-chippers built walls that mocked the mountains. But their god was Rallos Zek, the War Lord, and when he marched his legions into the Plane of Earth and lost, his curse came home with the survivors. It gnawed them down to me, the last chief, and then it gnawed me too. I keep the Amulet of Chieftains and wait for an heir that will never come. Tell Heshyrr what I told you: pride builds the walls that lock the dead inside.");
        quest::updatetaskactivity(600242, 2, 1);
      }
      else {
        quest::say("A voice? I see no staff. Only Heshyrr's Seeker's Spiritstaff lets the living look upon the dead. Return with it.");
      }
    }
    else {
      quest::say("The dead keep their own counsel, wanderer.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
