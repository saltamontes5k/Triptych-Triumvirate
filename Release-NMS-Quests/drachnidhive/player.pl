sub EVENT_ENTERZONE
{
	if (quest::istaskactive(500301) && quest::istaskactivityactive(500301, 0))
	{
		quest::updatetaskactivity(500301, 0, 1);
		$client->Message(15, "You slip through the hidden cleft into the Hive.");
	}
}