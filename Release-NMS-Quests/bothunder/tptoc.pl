
$instanceid = quest::GetInstanceID();

sub EVENT_SPAWN {
	quest::set_proximity($x - 40, $x + 40, $y - 40, $y + 40, $z - 40, $z + 40);
}

sub EVENT_ENTER {
	quest::MovePCInstance(209, $instanceid, -55, 315, -1490);
}

sub EVENT_SAY {
   if($text=~/hail/i)   {
					quest::MovePCInstance(209, $instanceid, -55, 315, -1490);


   }
}