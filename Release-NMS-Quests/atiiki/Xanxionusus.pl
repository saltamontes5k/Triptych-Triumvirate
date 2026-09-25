#--------------------------------------------------------------------------
# TBS: Xanxionusus - Jewel of Atiiki (418075)
# Repeat Paza's phrase to receive Paza's Cursed Remains (79516); necromancers
# only, matching the live behaviour.
#--------------------------------------------------------------------------
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Speak of nothing. The efreeti do not suffer idle words.");
    return;
  }

  if ($text=~/D.nik Belm J.cof Ghap/i) {
    quest::say('Paza has upheld the bargain, the recompense is granted as agreed... D`nik Belm J`cof Ghap!');
    if ($client->HasClassID(11)) {
      quest::say('I sense the darkness of your soul... These bones are no longer of any use to me; take them as compensation for your assistance in this matter... Leave quickly, and speak of this to no one.');
      quest::summonitem(79516);
    } else {
      quest::say("Although I am sure you acted out of ignorance, your assistance was useful... It would be best if you left now, I have many thoughts upon which to contemplate.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
