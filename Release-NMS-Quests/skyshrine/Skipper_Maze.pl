
$instanceid = quest::GetInstanceID();


sub EVENT_SAY {
   if($text=~/hail/i)   {
		quest::say("I can grant you passage beyond the [maze]! This is helpful for Skyshrine class armor quests and for people that don't like being stuck in infinite loops. Please just skip the maze unless you are in the open world.");
   }
   elsif($text=~/maze/i)	{
		quest::MovePCInstance(114, $instanceid, 659, -60, 3, 385);
   }
}