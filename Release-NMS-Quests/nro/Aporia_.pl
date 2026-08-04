# Aporia.pl
# Zone: Northern Desert of Ro (nro)

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::say("Dreams sometimes die hero, but their spirits live on in others. I see the wonders you have forged here, and you will find me again in the Hollowed lands.");
        quest::summonitem(25866, 20);
    }
}
