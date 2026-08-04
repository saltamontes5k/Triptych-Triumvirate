
$instanceid = quest::GetInstanceID();

sub EVENT_SPAWN {
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 1, $z + 0);
}

sub EVENT_ENTER {
	quest::MovePCInstance(209, $instanceid, -800, -1075, 2120, 128);
}

sub EVENT_SAY {
   if($text=~/hail/i)   {
				quest::MovePCInstance(209, $instanceid, -800, -1075, 2120, 128);









   }
}