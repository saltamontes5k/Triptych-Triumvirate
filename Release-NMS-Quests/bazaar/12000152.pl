# Card_Dealer_Tessa (bazaar, npc_types.id 12000152) -- Legends of Norrath card dealer.
#
#   * one free Oathbound starter deck per ACCOUNT: Fighter / Mage / Priest / Scout
#   * boosters at 5 Triune of Fate (alt currency 6, item 46779) each, in 1- or 5-packs
#
# Nothing is handed over in the world: card products are queued in lon_delivery and the
# card service hands them over the next time the account opens Legends of Norrath (within
# a few seconds if the client is already open). The free starter is recorded once per
# account in lon_vendor_claim.
#
# Product ids are the card game's own (lon_data/decks/): set N booster = N*1000000+900001;
# the Oathbound (set 1) starter decks are 1900002 Fighter, 1900003 Mage, 1900004 Priest,
# 1900005 Scout.

my $COST_PER_BOOSTER = 5;

my %STARTER_DECK = (
    1900002 => 'Fighter',
    1900003 => 'Mage',
    1900004 => 'Priest',
    1900005 => 'Scout',
);

my %BOOSTER_SET = (
    1  => 'Oathbound',
    2  => 'Forsworn',
    3  => 'Inquisitor',
    4  => 'Oathbreaker',
    5  => 'Ethernauts',
    6  => 'Against the Void',
    7  => 'Storm Break',
    8  => 'Travelers',
    9  => 'Vengeful Gods',
    10 => 'Doom of the Ancient Ones',
    11 => 'Dragonbrood - The Anarchs',
    12 => 'Legacies',
    13 => 'Priestess of the Anarchs',
    14 => 'Fall of the Estarim',
    15 => 'Debt of the Ratonga',
);

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::NPCTell(
            "Legends of Norrath, $name! Cards, campaigns and catastrophes. " .
            "Every account gets one free starter deck - pick your poison: " . StarterLinks() . "."
        );
        plugin::NPCTell(
            "After that I sell boosters at $COST_PER_BOOSTER " . plugin::TriuneOfFateLink() .
            " each, and you are carrying " . plugin::GetTriuneOfFate($client) . ". " .
            "[" . quest::saylink("buy", 1, "buy boosters") . "]"
        );
    }
    elsif ($text =~ /^starter\s+(\d+)$/i) {
        ClaimStarter($1);
    }
    elsif ($text =~ /^(buy|boosters|shop)$/i) {
        ShowSets();
    }
    elsif ($text =~ /^set\s+(\d+)$/i) {
        ShowSet($1);
    }
    elsif ($text =~ /^buy\s+(\d+)\s+(\d+)$/i) {
        BuyBoosters($1, $2);
    }
}

sub StarterLinks {
    return join(" ", map { "[" . quest::saylink("starter $_", 1, $STARTER_DECK{$_}) . "]" }
                     sort { $a <=> $b } keys %STARTER_DECK);
}

sub ShowSets {
    plugin::NPCTell(
        "Boosters are $COST_PER_BOOSTER " . plugin::TriuneOfFateLink() . " each. Which set?"
    );
    my @line;
    foreach my $set (sort { $a <=> $b } keys %BOOSTER_SET) {
        push @line, "[" . quest::saylink("set $set", 1, $BOOSTER_SET{$set}) . "]";
        if (@line == 5) {
            plugin::NPCTell(join(" ", @line));
            @line = ();
        }
    }
    plugin::NPCTell(join(" ", @line)) if @line;
}

sub ShowSet {
    my $set = shift;
    return unless exists $BOOSTER_SET{$set};

    plugin::NPCTell(
        $BOOSTER_SET{$set} . " boosters, $COST_PER_BOOSTER " . plugin::TriuneOfFateLink() . " each. " .
        "[" . quest::saylink("buy $set 1", 1, "1 booster - $COST_PER_BOOSTER") . "] " .
        "[" . quest::saylink("buy $set 5", 1, "5 boosters - " . ($COST_PER_BOOSTER * 5)) . "]"
    );
}

sub ClaimStarter {
    my $archetype = shift;
    return unless exists $STARTER_DECK{$archetype};

    my $account = $client->AccountID();
    my $dbh     = plugin::LoadMysql();
    unless ($dbh) {
        plugin::NPCTell("My ledger is out of reach just now. Come back in a moment and the deck is still yours.");
        return;
    }

    # The claim row is the gate: INSERT IGNORE tells us - atomically - whether this
    # account has already had its free deck.
    $dbh->begin_work;
    my $claimed = $dbh->do(
        "INSERT IGNORE INTO lon_vendor_claim (account_id, claim_key) VALUES (?, 'oathbound_starter')",
        undef, $account
    );
    if (!defined($claimed) || $claimed < 1) {
        $dbh->rollback;
        plugin::NPCTell(
            "One free deck per account, friend, and yours has already been dealt. " .
            "[" . quest::saylink("buy", 1, "buy boosters") . "] and build something mean."
        );
        return;
    }

    my $queued = $dbh->do(
        "INSERT INTO lon_delivery (account_id, archetype, quantity, source) VALUES (?, ?, 1, 'vendor:tessa')",
        undef, $account, $archetype
    );
    if (!defined($queued) || $queued < 1) {
        $dbh->rollback;
        plugin::NPCTell("The ledger smudged. Nothing was taken - ask me again.");
        return;
    }
    $dbh->commit;

    plugin::NPCTell(
        "An Oathbound " . $STARTER_DECK{$archetype} . " starter deck, sealed and waiting. " .
        "Open Legends of Norrath and it will be in your collection - pick it in Select Deck " .
        "and the first campaign is yours."
    );
    plugin::YellowText("Card Dealer Tessa granted you the Oathbound " . $STARTER_DECK{$archetype} . " starter deck.");
}

sub BuyBoosters {
    my ($set, $quantity) = @_;
    return unless exists $BOOSTER_SET{$set};

    $quantity = ($quantity == 5) ? 5 : 1;
    my $cost = $COST_PER_BOOSTER * $quantity;
    my $held = plugin::GetTriuneOfFate($client);
    if ($held < $cost) {
        plugin::NPCTell(
            "Boosters are $COST_PER_BOOSTER " . plugin::TriuneOfFateLink() . " each and you are carrying $held. " .
            "The bankers in this hall buy and sell Triunes, if you are short."
        );
        return;
    }

    # Spend first, then queue; if the queue write fails the Triunes go straight back.
    unless (plugin::SpendTriuneOfFate($client, $cost)) {
        plugin::NPCTell("Your Triunes slipped through my fingers - nothing was bought.");
        return;
    }

    my $archetype = $set * 1000000 + 900001;
    my $dbh = plugin::LoadMysql();
    my $queued = $dbh ? $dbh->do(
        "INSERT INTO lon_delivery (account_id, archetype, quantity, source) VALUES (?, ?, ?, 'vendor:tessa')",
        undef, $client->AccountID(), $archetype, $quantity
    ) : undef;
    if (!defined($queued) || $queued < 1) {
        $client->AddAlternateCurrencyValue(6, $cost);
        plugin::NPCTell("The ledger smudged - your Triunes are back and nothing was bought. Try again.");
        return;
    }

    my $word = ($quantity == 1) ? "booster" : "boosters";
    plugin::NPCTell(
        "$quantity " . $BOOSTER_SET{$set} . " $word, $cost " . plugin::TriuneOfFateLink() . ". " .
        "They are waiting in your card game collection - open Legends of Norrath and crack them."
    );
    plugin::YellowText(
        "Card Dealer Tessa: bought " . $quantity . "x " . $BOOSTER_SET{$set} . " $word for " .
        $cost . " Triune of Fate."
    );
}
