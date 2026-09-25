# Greater Soul Gem - AA activation.
# Consumes 50 unspent AA points and creates a tradeable Greater Soul Gem (item 7000001).
sub EVENT_SPELL_EFFECT_CLIENT {
	my $client = plugin::val('$client');

	if ($client->GetAAPoints() < 50) {
		$client->Message(15, "You lack AAs to fund a greater soul gem.");
		return;
	}

	$client->RemoveAAPoints(50);
	$client->SummonFixedItem(7000001, 1);
	$client->Message(15, "You have created a Greater Soul Gem.");
}
