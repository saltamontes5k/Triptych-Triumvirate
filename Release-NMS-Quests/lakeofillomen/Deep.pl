sub EVENT_SAY {
 if($text=~/hail/i){
  quest::emote("ignores you.");
 }
}

sub EVENT_SPAWN {
  $x = $npc->GetX();
  $y = $npc->GetY();
  # Set proximity
  quest::set_proximity($x-50,$x+50,$y-50,$y+50);
}

sub EVENT_ENTER {
 if(plugin::HasClassName($client, "Monk")){
  # Monk Epic 1.0
  quest::attack($name);
 }
}


# End of File