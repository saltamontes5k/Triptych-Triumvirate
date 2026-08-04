sub EVENT_CONNECT { 
    check_frog_zone();
    $client->SendToGuildHall();
  }

  sub EVENT_ZONE {
    check_frog_zone();
    $client->SendToGuildHall();
  }

  sub EVENT_ENTERZONE {
    check_frog_zone();
    $client->SendToGuildHall();
  }

  sub check_frog_zone {
    if ($client->GetRace() == 330) {
      if ($client->GetDeity() == 208) {
        $client->MovePC(8, 120, 129, -24, 0);
      }
    }
  }