sub guard_reset
{
	$client->SetGlobal("dod_500303_reward", 0, 5, "F");
}

sub EVENT_TASKACCEPTED
{
	if ($task_id == 500303)
	{
		guard_reset();
	}
}

sub advance_activity
{
	my ($act, $phrase) = @_;
	if (quest::istaskactivityactive(500303, $act))
	{
		quest::say($phrase);
		quest::updatetaskactivity(500303, $act, 1);
	}
}

sub EVENT_SAY
{
	if (!quest::istaskactive(500303))
	{
		if ($text =~ /Hail/i && $ulevel >= 70 && $ulevel <= 95)
		{
			quest::say("The waters speak of a shroud that was never buried. Ask me of the [Depths of Darkhollow] and I will tell you what was foretold.");
		}
		elsif ($text =~ /Depths of Darkhollow/i && $ulevel >= 70 && $ulevel <= 95)
		{
			quest::taskselector(500303);
		}
		return;
	}
	if ($text =~ /fibblebrap/i)
	{
		advance_activity(0, "The old one has taken refuge in the Creep of Corathus. Find him and learn what he knows.");
	}
	elsif ($text =~ /longshadow/i)
	{
		advance_activity(1, "Elder Longshadow walked into Undershore alone. The waters remember the rest.");
	}
	elsif ($text =~ /leviathan/i)
	{
		advance_activity(2, "The Korlach Leviathan stirs beneath the falls. Survive it if you are to go deeper.");
	}
	elsif ($text =~ /prophecy/i)
	{
		advance_activity(3, "As foretold, the prophet's words are fulfilled among the ruined spires of Illsalin.");
	}
	elsif ($text =~ /ecologist/i)
	{
		advance_activity(4, "The Ecologist lies lost within the Hive. Bring word that the expedition endures.");
	}
	elsif ($text =~ /shroud/i)
	{
		advance_activity(5, "Gather the werewolf skull fragments and lay them to rest in Den Lord Rakban's shroud.");
	}
	elsif ($text =~ /Hail/i)
	{
		quest::say("Speak to me of [Fibblebrap], [Longshadow], the [Leviathan], the [Prophecy], the [Ecologist], or the [shroud].");
	}
	if (!$client->GetGlobal("dod_500303_reward") && !quest::istaskactive(500303) && $ulevel >= 70 && $ulevel <= 95)
	{
		$client->SetGlobal("dod_500303_reward", 1, 5, "F");
		quest::say("The skull is yours. Kindle it carefully, and it will grow with you.");
		quest::summonitem(85571);
	}
}