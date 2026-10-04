-- Loremaster of the Timeshear (478751) -- SoD Rank III spells (thevoidb).
-- miscProgression: raid targets unlock Rank 3 spells in The Void.
-- Spell lists: plugins/NMS_sod_rk3_data.pl; rules in
-- plugins/NMS_sod_utils.pl (plugin::SodLoremaster).

sub EVENT_SAY {
	plugin::SodLoremaster($client, 478751, $text);
}
