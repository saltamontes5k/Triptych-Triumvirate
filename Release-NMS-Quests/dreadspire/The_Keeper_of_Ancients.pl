sub EVENT_SAY
{
	if ($text =~ /Hail/i)
	{
		quest::say("The ancients left pieces of themselves scattered across the Demi-Plane. Bring me the sixteen [shards] of the ancients and I will forge them into something worthy of a hero.");
	}
	elsif ($text =~ /shards/i)
	{
		quest::say("Sixteen shards, one for each path of power. Gather them all and return to me. I will not accept a partial offering.");
	}
}

sub EVENT_ITEM
{
	my @shards = (89471, 89472, 89473, 89474, 89475, 89476, 89477, 89478, 89479, 89480, 89481, 89482, 89483, 89484, 89485, 89486);
	my %need = ();
	my $found = 0;

	foreach my $id (@shards)
	{
		if ($itemcount{$id})
		{
			$need{$id} = 1;
			$found++;
		}
	}

	if ($found > 0)
	{
		if (scalar(keys %need) == 16)
		{
			plugin::check_handin(\%itemcount, %need);
			quest::emote("accepts the shards and sets them spinning in the air. Light floods the chamber as the pieces fuse into a single augment.");
			quest::say("It is done. Take it, hero, and let the ancients fight beside you.");
			quest::summonitem(900503);
		}
		else
		{
			quest::say("You carry only $found of the sixteen shards. Return when the set is complete.");
		}
	}

	plugin::return_items(\%itemcount);
}