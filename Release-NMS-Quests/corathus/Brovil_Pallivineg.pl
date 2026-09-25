my @sections = (84041, 84042, 84043, 84044, 84045, 84046, 84047, 84048, 84049);

sub grid_key
{
	my $charid = $client->CharacterID();
	return "dod_notebook_" . $charid;
}

sub delivered_list
{
	return $client->GetGlobal(grid_key());
}

sub save_delivered
{
	my $list = shift;
	$client->SetGlobal(grid_key(), $list, 5, "F");
}

sub EVENT_SAY
{
	if ($text =~ /Hail/i)
	{
		if (quest::istaskactive(500301))
		{
			quest::say("Cicero's work was torn apart and scattered through the Hive. Bring me the sections and I will restore it.");
		}
		elsif ($ulevel >= 69 && $ulevel <= 125)
		{
			quest::say("Curious about the [Lost Notebook]? It belonged to a scholar of my order, before the drachnids dragged him into the Hive.");
		}
	}
	elsif ($text =~ /Lost Notebook/i)
	{
		if (!quest::istaskactive(500301) && $ulevel >= 69 && $ulevel <= 125)
		{
			quest::taskselector(500301);
		}
	}
}

sub EVENT_ITEM
{
	if (quest::istaskactive(500301) && quest::istaskactivityactive(500301, 1))
	{
		my $current = delivered_list() || "";
		my %have = map { $_ => 1 } grep { length($_) } split(/,/, $current);

		my %need = ();
		foreach my $s (@sections)
		{
			if ($itemcount{$s} && !$have{$s})
			{
				$need{$s} = $itemcount{$s};
			}
		}

		if (keys %need)
		{
			plugin::check_handin(\%itemcount, %need);
			foreach my $s (keys %need)
			{
				$have{$s} = 1;
			}
			my $count = scalar(keys %have);
			my @sorted = sort { $a <=> $b } keys %have;
			save_delivered(join(",", @sorted));
			quest::say("Another section. That is $count of nine.");
			if ($count >= 9)
			{
				quest::updatetaskactivity(500301, 1, 1);
				save_delivered("");
				if (plugin::HasClassName($client, "Cleric") || plugin::HasClassName($client, "Druid") || plugin::HasClassName($client, "Shaman") || plugin::HasClassName($client, "Necromancer") || plugin::HasClassName($client, "Wizard") || plugin::HasClassName($client, "Magician") || plugin::HasClassName($client, "Enchanter"))
				{
					quest::summonitem(83671);
				}
				else
				{
					quest::summonitem(83670);
				}
			}
		}
	}
	plugin::return_items(\%itemcount);
}