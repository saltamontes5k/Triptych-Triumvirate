# Monk Epic 1.0
# items: 1685
sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(3);
}

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::emote("whispers: Here is Santug's list... Tell him that Miragul is responsible for this... You must save us all.");
    quest::summonitem(67713);   
  }
}
