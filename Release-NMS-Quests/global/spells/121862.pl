# Spell 121862 - Glyph of the Gambler (aa_ability 31088 / rank 41010)
#
# Activating the Glyph of the Gambler summons one completely random item from
# the gambler_item_pool table (curated; extend with plain INSERTs). The spell
# itself carries no native effects - everything happens here.
#
# See: Release-NMS-Server/utils/sql/20261004_glyphs_blood_gambler.sql

sub EVENT_SPELL_EFFECT_CLIENT {
    my $item_id = 0;

    my $dbh = plugin::LoadMysql();
    if ($dbh) {
        my $sth = $dbh->prepare(
            "SELECT gip.item_id, i.Name " .
            "FROM gambler_item_pool gip " .
            "JOIN items i ON i.id = gip.item_id " .
            "ORDER BY RAND() LIMIT 1"
        );
        $sth->execute();
        my ($pool_item, $item_name) = $sth->fetchrow_array();
        $sth->finish();
        $dbh->disconnect();

        if ($pool_item) {
            $item_id = $pool_item;
            $item_name = "an unidentified prize" unless $item_name;
            $client->Message(15, "The Glyph flares and grants you: " . quest::varlink($item_id, $item_name));
        }
    }

    unless ($item_id) {
        $client->Message(13, "The Glyph sputters - the Gambler's hoard is unreachable. Your points were not spent in vain; try again.");
        return;
    }

    quest::summonitem($item_id);
}

1;
