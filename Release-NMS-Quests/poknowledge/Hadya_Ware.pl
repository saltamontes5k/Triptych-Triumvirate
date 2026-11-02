# Hadya Ware - Plane of Knowledge, Nights of the Dead mercenary quartermaster.
# Live-seasonal she redeems mercenary contracts; no contract quest exists on this
# server, so she steers visitors to the season's vendors. Seasonal: flag-gated spawn.
sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Well met. I keep the quartermaster's ledger for the season's muster - though the contracts have been quiet this year. The [" . quest::saylink("festivities") . "], however, are in full swing.");
	}
	elsif ($text=~/festivities/i) {
		quest::say("Spooky Sally has costumes, Haunted Jack has candy, and the whole square smells of caramel apples. Wicked Winnie is cooking up something of her own, if you fancy a chore.");
	}
}
