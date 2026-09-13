# Banker_Yalon (bazaar, npc_types.id 12000149) - Triune of Fate <-> Platinum money changer.
# Rate: 20,000pp = 5 Triune of Fate (alt currency 6, item 46779) => 4,000pp per Triune of Fate.
# One conversion per saylink click, in either direction.

my $pp_per_tof = 4000;

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::NPCTell(
            "Psst. Over here, $name. The other bankers count coins - I transmute them. " .
            "My rate never changes: five " . plugin::TriuneOfFateLink() . " for twenty thousand platinum, " .
            "one [conversion] per trade, no refunds, no questions asked."
        );
        ShowBalances();
    }
    elsif ($text =~ /conversion/i) {
        plugin::NPCTell(
            "Which way does the tide flow for you today? " .
            "[" . quest::saylink("pp_to_tof", 1, "trade " . commaify($pp_per_tof) . " platinum for one Triune of Fate") . "] " .
            "or [" . quest::saylink("tof_to_pp", 1, "trade one Triune of Fate for " . commaify($pp_per_tof) . " platinum") . "]?"
        );
    }
    elsif ($text =~ /^pp_to_tof$/i) {
        ConvertPPtoTOF();
    }
    elsif ($text =~ /^tof_to_pp$/i) {
        ConvertTOFtoPP();
    }
}

sub ConvertPPtoTOF {
    unless ($client->TakeMoneyFromPP($pp_per_tof * 1000, 1)) {
        plugin::NPCTell(
            "You're a bit light in the coin purse, friend. Come back with " .
            commaify($pp_per_tof) . " platinum in hand and we'll talk."
        );
        return;
    }

    $client->AddAlternateCurrencyValue(6, 1);
    plugin::NPCTell(
        "The coins vanish and something far more interesting appears in their place. " .
        "A pleasure doing business with you, $name."
    );
    plugin::YellowText("Traded " . commaify($pp_per_tof) . "pp for 1 Triune of Fate.");
    ShowBalances();
}

sub ConvertTOFtoPP {
    unless (plugin::GetTriuneOfFate($client) >= 1 && plugin::SpendTriuneOfFate($client, 1)) {
        plugin::NPCTell(
            "You haven't a single " . plugin::TriuneOfFateLink() . " to your name. " .
            "Come back when the Triunes favor you."
        );
        return;
    }

    $client->AddMoneyToPP(0, 0, 0, $pp_per_tof, 1);
    plugin::NPCTell(
        "Ah, surrendering fate back to the bankers. Very well - cold, hard coin it is. " .
        "A pleasure doing business with you, $name."
    );
    plugin::YellowText("Traded 1 Triune of Fate for " . commaify($pp_per_tof) . "pp.");
    ShowBalances();
}

sub ShowBalances {
    plugin::YellowText(
        "You carry " . commaify(int($client->GetCarriedMoney() / 1000)) . "pp and hold " .
        plugin::GetTriuneOfFate($client) . " " . plugin::TriuneOfFateLink() . "."
    );
}

sub commaify {
    my $number = shift;
    $number =~ s/(?<=\d)(?=(\d{3})+(?!\d))/,/g;
    return $number;
}
