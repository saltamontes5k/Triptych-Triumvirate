# Karanite Rainfall (True Karanite Rod of Rainfall, blessing task 700154)
# The rod calls rain down on the dry places; the storm god counts each one.
#
# Spell 44031 deliberately carries no spell effect. It used to carry effectid1
# = 528, an invented "SE_StartRain" SPA -- but 528 is live EverQuest's "Clear
# Faction" effect, so the client (and MQ2) described the rod's click as a
# faction wipe. The weather is started here instead, mirroring the way Wake of
# Karana (effect 93) stops the rain.
%RAIN_STEPS = (
	30  => 2,  # Everfrost
	279 => 3,  # Abysmal Sea
	224 => 4,  # Gunthak
	68  => 5,  # Butcherblock
	175 => 6,  # Scarlet Desert
	202 => 7,  # Plane of Knowledge
);

sub EVENT_SPELL_EFFECT_CLIENT {
	my $client = $entity_list->GetClientByID($caster_id);
	return unless $client;

	# 1 = rain, 0 = clear (EQ::constants::WeatherTypes). Zone-wide, like the SPA.
	quest::rain(1);

	return unless $client->IsTaskActive(700154);

	my $act = $RAIN_STEPS{$client->GetZoneID()};
	return unless defined $act;
	$client->UpdateTaskActivity(700154, $act, 1);
	$client->Message(4, "Rain begins to fall. Karana's blessing spreads across the land.");
}
