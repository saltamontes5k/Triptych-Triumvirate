# Arid Indicolite Shard (87222) - Vergalid Mines
# The Serpent's Spine :: Access to the Ancient Ruins (Inner Vergalid)
# Right-click the shard while standing among the blue crystals of the Shrine
# of Zek in the NE of the zone (crystal formation OBJ_VM_CRYSTALB_A at
# -1598, 880, -452; shrine room spans roughly x -1650..-1400, y 817..977).
# The shard is infused and becomes the permanent Flawless Indicolite Shard
# (87246), the key to the stone statue gate on the east side of the shrine.
# Clicks anywhere else only feed the shard's power into Vergalid's life
# stream; the shard survives (maxcharges 0).

sub EVENT_ITEM_CLICK {
	my $client = shift;
	return unless $client;

	if ($zoneid == 404 && $client->CalculateDistance(-1520.0, 880.0, -430.0) <= 200) {
		quest::summonitem(87246); # Flawless Indicolite Shard
		quest::removeitem(87222, 1);
		$client->Message(4, "You infuse the crystal's power into Vergalid's life stream.");
	}
	else {
		$client->Message(13, "The shard's dull energies drain away harmlessly, feeding the life stream of the mines.");
	}
}
