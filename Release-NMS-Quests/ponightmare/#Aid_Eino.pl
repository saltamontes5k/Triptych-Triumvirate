sub EVENT_SPAWN {
  my $x = $npc->GetX();
  my $y = $npc->GetY();
  quest::set_proximity($x-50, $x+50, $y-50, $y+50, -999999, 999999, 1);
  quest::enable_proximity_say();
}

sub EVENT_PROXIMITY_SAY {
  if (($zonehour > 19 || $zonehour < 6) && ($text=~/quellious be my guide/i) && ($client->GetAccountBucket("eino-trigger") == "1")) {
    $client->SetAccountBucket("eino-trigger", "0");
    quest::unique_spawn(204071,0,0,1685,-515,215,310); # NPC: Aid_Eino
    quest::depop_withtimer();
  }
}
