# Scout Zialdiruun (456003) -- Army of Obliteration scout by the Bloody
# Kithicor rift. Hands the faction medallion to those who would serve
# Lanys T`Vyl's host; the medallion is required to interact with the
# Obliteration officers (raspersrealm themeKithicor).
sub EVENT_SAY {
    if ($text =~ /hail/i) {
        if ($client->CountItem(41119) > 0) {
            quest::say("The Obliteration sees its own. Serve, and be rewarded.");
        } else {
            quest::summonitem(41119);    # Army of Obliteration Medallion
            quest::say("So you would serve the Army of Obliteration. Wear this medallion -- Lanys T`Vyl's officers answer only to their own colors.");
        }
    }
}
