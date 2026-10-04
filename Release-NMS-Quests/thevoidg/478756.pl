-- Loremaster of the Timeshear (478756) -- SoD Rank III spells (thevoidg).
-- miscProgression: raid targets unlock Rank 3 spells in The Void.
-- Spell lists: plugins/NMS_sod_rk3_data.pl; rules in
-- plugins/NMS_sod_utils.pl (plugin::SodLoremaster).

sub EVENT_SAY {
	plugin::SodLoremaster($client, 478756, $text);
}
