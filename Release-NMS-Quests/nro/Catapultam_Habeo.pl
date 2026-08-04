# Catapultum.pl
# Zone: Northern Desert of Ro (nro)

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::say("Never falter, hero. Stay true to your vows. For when our paths cross again, we will ask you to take the Oath.");
        quest::summonitem(25865, 20);
    }
}
