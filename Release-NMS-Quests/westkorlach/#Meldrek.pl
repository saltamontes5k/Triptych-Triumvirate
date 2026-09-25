sub EVENT_SAY
{
	if ($text =~ /Hail/i)
	{
		if (quest::istaskactive(500300))
		{
			quest::say("Keep your head down, friend. This field belongs to the drachnids. When you are ready to slip past them, speak of the [alternate entrance].");
			if (quest::istaskactivityactive(500300, 0))
			{
				quest::updatetaskactivity(500300, 0, 1);
			}
		}
		elsif ($ulevel >= 65 && $ulevel <= 125)
		{
			quest::say("Kelliad vouches for you. You want past the gates, do you? Ask about the [alternate entrance].");
		}
	}
	elsif ($text =~ /alternate entrance/i)
	{
		if (quest::istaskactive(500300))
		{
			quest::say("There is a hidden way below the falls. Say you wish to [venture into the lairs] and I will send you through.");
		}
		elsif ($ulevel >= 65 && $ulevel <= 125)
		{
			quest::taskselector(500300);
		}
	}
	elsif ($text =~ /venture into the lairs/i)
	{
		if (quest::istaskactive(500300))
		{
			quest::say("Go now, and be quick about it. The drachnids will scent you soon enough.");
			quest::movepc(359, -1549, 577, 4);
		}
	}
}