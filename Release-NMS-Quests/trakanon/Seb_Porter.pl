sub EVENT_SAY {
  if ($text=~/hail/i)
  {
	#quest::say("Have some PvP! To turn it off, either zone, camp, or die! Let me know if you'd like to [participate] in the Arena Challenge! (This is not yet enabled!)");
	quest::movepc(89, 0, 250, 40, 255);
  }
}