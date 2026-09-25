sub EVENT_ENTERZONE
{
	if (quest::istaskactive(500302) && quest::istaskactivityactive(500302, 0))
	{
		quest::updatetaskactivity(500302, 0, 1);
		$client->Message(15, "You descend into the Nargilor Pits of Illsalin.");
	}
}