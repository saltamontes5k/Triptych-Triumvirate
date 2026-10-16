# Multi-quest (MQ) handin tracking, PEQ-compatible call contract.
# Backs rathemtn/Hasten_Bootstrutter.pl and qeytoqrg/Guard_Cheslin.pl.
#
# plugin::mq_process_items(\%itemcount)
#   Call at the top of EVENT_ITEM: credits every item the client just
#   surrendered toward this NPC's multi-quest progress.
# plugin::mq_process_items(itemid => count, ...)
#   Credits specific items named by a handin branch. Items already
#   credited by the top-of-event call in the same turn are not re-counted.
# plugin::check_mq_handin(itemid => count, ...)
#   True once every listed item has been surrendered to this NPC, in one
#   turn or many. Consumes the credit on success so the reward cannot
#   be repeated.
#
# Progress is keyed by NPC type id and lives in process memory; it resets
# on zone restart, which is acceptable for these 4-hour-depop quests.

use strict;
use warnings;

my %_mq_ledger;     # npc type id -> { item id -> credited count }
my %_mq_this_turn;  # npc type id -> { item id -> credited this event }

sub mq_process_items {
	my $npc = plugin::val('$npc') or return;
	my $key = $npc->GetNPCTypeID();
	if (ref($_[0]) eq 'HASH') {
		my $itemcount = shift;
		%{$_mq_this_turn{$key}} = ();    # a new EVENT_ITEM turn begins
		foreach my $id (keys %$itemcount) {
			next unless $id =~ /^\d+$/;
			my $n = $itemcount->{$id};
			$_mq_ledger{$key}{$id}    += $n;
			$_mq_this_turn{$key}{$id} += $n;
		}
		return;
	}
	my %items = @_;
	foreach my $id (keys %items) {
		next unless $id =~ /^\d+$/;
		my $still = $items{$id} - ($_mq_this_turn{$key}{$id} || 0);
		next if $still <= 0;
		$_mq_ledger{$key}{$id}    += $still;
		$_mq_this_turn{$key}{$id} += $still;
	}
}

sub check_mq_handin {
	my $npc = plugin::val('$npc') or return 0;
	my $key = $npc->GetNPCTypeID();
	my %req = @_;
	foreach my $id (keys %req) {
		return 0 unless ($_mq_ledger{$key}{$id} || 0) >= $req{$id};
	}
	foreach my $id (keys %req) {
		$_mq_ledger{$key}{$id} -= $req{$id};
		delete $_mq_ledger{$key}{$id} if $_mq_ledger{$key}{$id} <= 0;
	}
	return 1;
}

1;
