sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::whisper("Hail, $name. I am the Echo of Memory, keeper of forgotten moments. "
            . "I trade in the currency of remembrances. You may ["
            . quest::saylink("buy_eom", 1, "trade 2,500 platinum for 1 Echo of Memory")
            . "] with me.");
    }
    elsif ($text =~ /buy_eom/i) {
        my $cost_per_eom = 2500000;
        my $total_platinum = $client->GetMoney(3, 0);
        my $total_gold = $client->GetMoney(2, 0);
        my $total_silver = $client->GetMoney(1, 0);
        my $total_copper = $client->GetMoney(0, 0);
        my $total_money = ($total_platinum * 1000) + ($total_gold * 100) + ($total_silver * 10) + $total_copper;
        my $max_eoms = int($total_money / $cost_per_eom);

        if ($max_eoms > 0) {
            quest::whisper("Confirm trade: ["
                . quest::saylink("confirm_eom", 1, "Yes, trade " . ($max_eoms * 2500) . " platinum for $max_eoms Echo(s) of Memory")
                . "] or ["
                . quest::saylink("cancel_eom", 1, "No, cancel")
                . "].");
        }
        else {
            quest::whisper("You need at least 2,500 platinum to trade.");
        }
    }
    elsif ($text =~ /^confirm_eom$/i) {
        my $cost_per_eom = 2500000;
        my $total_platinum = $client->GetMoney(3, 0);
        my $total_gold = $client->GetMoney(2, 0);
        my $total_silver = $client->GetMoney(1, 0);
        my $total_copper = $client->GetMoney(0, 0);
        my $total_money = ($total_platinum * 1000) + ($total_gold * 100) + ($total_silver * 10) + $total_copper;
        my $max_eoms = int($total_money / $cost_per_eom);

        if ($max_eoms > 0) {
            if ($client->TakeMoneyFromPP($cost_per_eom * $max_eoms, 1)) {
                $client->AddAlternateCurrencyValue(6, $max_eoms);
                quest::whisper("You hand over " . ($max_eoms * 2500) . " platinum. The Echo of Memory accepts your payment and grants you " . $max_eoms . " fragments of remembered time.");
            }
            else {
                quest::whisper("You don't have enough platinum on you. Come back when you do.");
            }
        }
        else {
            quest::whisper("You need at least 2,500 platinum to trade.");
        }
    }
    elsif ($text =~ /cancel_eom/i) {
        quest::whisper("Trade cancelled.");
    }
}
