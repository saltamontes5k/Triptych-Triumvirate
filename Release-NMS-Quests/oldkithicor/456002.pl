# Scout Talendien (456002) -- Army of Light scout by the Bloody Kithicor
# rift. Hands the faction pendant to anyone willing to wear the Light's
# colors; the pendant is required to interact with the Light's officers
# (raspersrealm themeKithicor: you may own both necklaces and swap per
# quest line).
sub EVENT_SAY {
    if ($text =~ /hail/i) {
        if ($client->CountItem(41118) > 0) {
            quest::say("Wear the Light's colors with pride. The Obliteration scout across the woods carries the other pendant, if you mean to walk both roads.");
        } else {
            quest::summonitem(41118);    # Army of Light Pendant
            quest::say("So you would stand with the Light. Take this pendant and wear it -- our commanders in these woods answer only to their own colors.");
        }
    }
}
