# Bag of Seeds (84231) - Crescent Reach
# The Serpent's Spine :: Reclaim the Farm (task 600255, activity 0).
# Click to plant a row of seeds on the farm field (the farm grounds lie
# around x -2020, y 490); ten rows finish the task step.

sub EVENT_ITEM_CLICK {
	my $client = shift;
	return unless $client;

	if (quest::istaskactivityactive(600255, 0)) {
		if ($client->CalculateDistance(-2020.0, 490.0, -103.0) <= 350) {
			quest::updatetaskactivity(600255, 0, 1);
		}
		else {
			$client->Message(13, "These seeds want tilled soil. The farm fields lie across the stream in the Hollow.");
		}
	}
	else {
		$client->Message(13, "A bag full of seeds. Someone's farm is missing them.");
	}
}
