sub EVENT_SCALE_CALC {
    my $participation_value = quest::get_data($client->AccountID() . "-season-1-participation") || 0;
    my $participation_max   = 100;

    if (quest::get_data($client->AccountID() . "-season-1-participation-RoK")) {
        $participation_value += 10;
    }

    if (quest::get_data($client->AccountID() . "-season-1-participation-SoV")) {
        $participation_value += 10;
    }

    if (quest::get_data($client->AccountID() . "-season-1-participation-SoL")) {
        $participation_value += 10;
    }

    if (quest::get_data($client->AccountID() . "-season-1-participation-PoP")) {
        $participation_value += 10;
    }

    if (quest::get_data($client->AccountID() . "-season-1-participation-FNagafen")) {
        $participation_value += 10;
    }

    if ($participation_value > $participation_max) {
        $participation_value = $participation_max;
    }

    my $value = $participation_value / $participation_max;

    if ($value > 1) {
        $value = 1;
    }

    $questitem->SetScale($value);
}