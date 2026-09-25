# Greater Soul Gem - item click.
# Grants 50 AA points; the server consumes one gem after the cast.
sub EVENT_SPELL_EFFECT_CLIENT {
	my $client = plugin::val('$client');
	$client->AddAAPoints(50);
	$client->Message(15, "The Greater Soul Gem crumbles, granting you 50 AA points.");
}
