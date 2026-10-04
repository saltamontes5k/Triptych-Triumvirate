-- Loremaster of the Timeshear (478750) -- SoD Rank III spells (thevoida).
-- miscProgression: raid targets unlock Rank 3 spells in The Void.
-- Spell lists: plugins/NMS_sod_rk3_data.pl; rules in
-- plugins/NMS_sod_utils.pl (plugin::SodLoremaster).

sub EVENT_SAY {
	plugin::SodLoremaster($client, 478750, $text);
}
