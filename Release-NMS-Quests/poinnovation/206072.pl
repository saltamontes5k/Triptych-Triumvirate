# NPCID: a_clockwork_device (power carrier) - feeds the Manaetic Behemoth if it reaches the machine.
sub EVENT_SPAWN {
  quest::settimer("arrival_check",1);
  quest::settimer("failsafe_depop",180);
}

sub EVENT_TIMER {
  if($timer eq "arrival_check" && abs($npc->GetX() - 1125) <= 20 && abs($npc->GetY()) <= 20) {
    quest::signalwith(206046,1,1); # NPC: Manaetic_Behemoth
    $npc->CastSpell(2321,$npc->GetID()); # Spell: Energy Burst
    quest::depop();
  } elsif($timer eq "failsafe_depop") {
    quest::depop();
  }
}
