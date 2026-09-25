sub EVENT_SAY
{
	if ($text =~ /Hail/i && quest::istaskactive(500300) && quest::istaskactivityactive(500300, 3))
	{
		quest::say("The hearts, friend. Hand me four drachnid hearts and the mask is yours.");
	}
}

sub EVENT_ITEM
{
	if (quest::istaskactive(500300) && quest::istaskactivityactive(500300, 3))
	{
		my $h1 = $itemcount{83363} || 0;
		my $h2 = $itemcount{85029} || 0;
		if ($h1 + $h2 >= 4)
		{
			my $take1 = ($h1 >= 4) ? 4 : $h1;
			my $take2 = 4 - $take1;
			my %need = (83363 => $take1, 85029 => $take2);
			plugin::check_handin(\%itemcount, %need);
			quest::updatetaskactivity(500300, 3, 1);
			if (plugin::HasClassName($client, "Cleric") || plugin::HasClassName($client, "Druid") || plugin::HasClassName($client, "Shaman") || plugin::HasClassName($client, "Necromancer") || plugin::HasClassName($client, "Wizard") || plugin::HasClassName($client, "Magician") || plugin::HasClassName($client, "Enchanter"))
			{
				quest::say("A proper ward against the depths. Wear it well.");
				quest::summonitem(86766);
			}
			else
			{
				quest::say("This mask has seen every scar this city can give. Make it yours.");
				quest::summonitem(86765);
			}
		}
	}
	plugin::return_items(\%itemcount);
}