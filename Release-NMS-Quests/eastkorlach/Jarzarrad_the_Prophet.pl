sub EVENT_SAY
{
	if (quest::istaskactive(500302))
	{
		if ($text =~ /captives/i && quest::istaskactivityactive(500302, 1))
		{
			quest::say("Then you have seen what Draygun hoards in the Pits. Mark it well, for it must be made to stop.");
			quest::updatetaskactivity(500302, 1, 1);
		}
		elsif ($text =~ /guardian/i && quest::istaskactivityactive(500302, 2))
		{
			quest::say("The Guardian of the Pit stands between the captives and the surface. It must not block our way.");
			quest::updatetaskactivity(500302, 2, 1);
		}
		elsif ($text =~ /legion/i && quest::istaskactivityactive(500302, 3))
		{
			quest::say("Ten of the Captured Legion Soldiers fell to your blade. Draygun's grip on the Pits loosens.");
			quest::updatetaskactivity(500302, 3, 1);
		}
		elsif ($text =~ /victory/i && quest::istaskactivityactive(500302, 4) && !quest::istaskactivityactive(500302, 1) && !quest::istaskactivityactive(500302, 2) && !quest::istaskactivityactive(500302, 3))
		{
			quest::say("The prophecy turns, and it turns because of you. Take what you have earned in the depths.");
			quest::updatetaskactivity(500302, 4, 1);
			if (plugin::HasClassName($client, "Cleric") || plugin::HasClassName($client, "Druid") || plugin::HasClassName($client, "Shaman") || plugin::HasClassName($client, "Necromancer") || plugin::HasClassName($client, "Wizard") || plugin::HasClassName($client, "Magician") || plugin::HasClassName($client, "Enchanter"))
			{
				quest::summonitem(83863);
			}
			else
			{
				quest::summonitem(83862);
			}
		}
		elsif ($text =~ /Hail/i)
		{
			quest::say("Speak to me of the [captives], the [guardian], or the [legion], and when all three are done, speak of [victory].");
		}
	}
	elsif ($text =~ /Hail/i && $ulevel >= 70 && $ulevel <= 125)
	{
		quest::say("The shiliskin think themselves secure beneath Illsalin. Ask me of the [Preemptive Strike] and I will send you among them.");
	}
	elsif ($text =~ /Preemptive Strike/i && $ulevel >= 70 && $ulevel <= 125)
	{
		quest::taskselector(500302);
	}
}