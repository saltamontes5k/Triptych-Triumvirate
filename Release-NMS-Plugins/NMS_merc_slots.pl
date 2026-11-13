# NMS_merc_slots.pl
# Universal mercenary contract-slot vendor, called from global_npc.pl for every
# class-71 mercenary liaison. Five Triune of Fate (alt currency 6) per extra
# owned-contract slot. Base 3 slots, compiled ceiling 11.
#
# Returns 1 when it handled the say text, 0 otherwise.

sub MercSlotVendorSay {
	my ($client, $text) = @_;
	return 0 unless $client && defined $text;
	return 0 unless $client->can('GetMercenaryCapacity') && $client->can('SendMercenaryInfo');

	my $SLOT_COST = 5;
	my $SLOT_KEY  = "eqemu.mercenary.extra_slots";
	my $MAX_SLOTS = 11;

	my $capacity = $client->GetMercenaryCapacity();

	if ($text =~ /hail/i) {
		my $link = "[" . quest::saylink("merc_slots", 1, "unlock another contract slot") . "]";
		plugin::Whisper("Your mercenary ledger holds $capacity contract"
			. ($capacity == 1 ? "" : "s")
			. ". For $SLOT_COST Triune of Fate I can add another. $link");
		return 1;
	}

	if ($text eq "merc_slots") {
		if ($capacity >= $MAX_SLOTS) {
			plugin::Whisper("Your ledger already holds the maximum of $MAX_SLOTS contracts.");
			return 1;
		}

		my $held = $client->GetAlternateCurrencyValue(6);
		if ($held < $SLOT_COST) {
			plugin::Whisper("You hold $held Triune of Fate; I need $SLOT_COST for another slot.");
			return 1;
		}

		if (!plugin::SpendTriuneOfFate($client, $SLOT_COST)) {
			plugin::Whisper("The coin did not take. Try again in a moment.");
			return 1;
		}

		my $purchased = int($client->GetBucket($SLOT_KEY)) + 1;
		$client->SetBucket($SLOT_KEY, "$purchased");
		$client->SendMercenaryInfo();

		plugin::Whisper("Done. Your ledger now holds " . $client->GetMercenaryCapacity()
			. " contracts. Open your Mercenary Manage window to see the new slot.");
		return 1;
	}

	return 0;
}
