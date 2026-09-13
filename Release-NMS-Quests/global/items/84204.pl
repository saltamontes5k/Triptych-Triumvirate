# Jar of the Windspirit (84204) - Crescent Reach
# The Serpent's Spine :: Reakash's Serenity (task 600246, activity 2).
# Click near the waterfalls of the Hollow (x -2391, y -1650, z -218) to fill
# the jar with mist and receive the Jar of Mist (84203).

sub EVENT_ITEM_CLICK {
	my $client = shift;
	return unless $client;

	if (quest::istaskactivityactive(600246, 2)) {
		# The waterfalls where the stream leaves/enters the Hollow.
		if ($client->CalculateDistance(-2391.0, -1650.0, -218.0) <= 200) {
			quest::summonitem(84203); # Jar of Mist
			$client->Message(4, "You hold the jar into the roiling mist of the falls. The windspirit's vessel fills with cold vapor.");
			quest::updatetaskactivity(600246, 2, 1);
		}
		else {
			$client->Message(13, "The jar hangs empty. The mist of the waterfalls of the Hollow would fill it.");
		}
	}
	else {
		$client->Message(13, "The windspirit's jar is quiet. It seems to be waiting for an errand.");
	}
}
