# items: 29281, 29292
sub EVENT_SPAWN
{
	quest::settimer("depop", 120);
	quest::settimer("fd", 1);
}

sub EVENT_TIMER
{
	if ($timer eq "fd") {
		$npc->SetAppearance(3); # fallen prone
		quest::stoptimer("fd");
	}
	else {
		quest::depop();
	}
}

sub EVENT_ITEM
{
	if(plugin::check_handin(\%itemcount, 29281 => 1))
	{
		quest::summonitem(29281); # Item: Box of Souls
		quest::summonitem(29292); # Item: Soul Sphere
	}
	plugin::return_items(\%itemcount);
}