my $jailX;
my $jailY;
my $jailZ;
my $jailW;

sub EVENT_SPAWN {
	#:: Create a proximity, 150 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 75, $x + 75, $y - 75, $y + 75, $z - 50, $z + 50, 0);
	$jailX = $npc->GetX();
	$jailY = $npc->GetY();
	$jailZ = $npc->GetZ();
	$jailW = $npc->GetHeading();
	my @clist = $entity_list->GetClientList();
	foreach my $c (@clist) {
		if ($c->CalculateDistance($x, $y, $z) < 150) {
			my $random = int(rand(6)) + 1;
			if ($random == 1) {
				$client->MovePC($zoneid, $jailX + 10, $jailY - 10, $jailZ, $jailW);
			}
			elsif ($random == 2) {
				$client->MovePC($zoneid, $jailX - 10, $jailY + 10, $jailZ, $jailW);
			}
			elsif ($random == 3) {
				$client->MovePC($zoneid, $jailX + 10, $jailY - 10, $jailZ, $jailW);
			}
			elsif ($random == 4) {
				$client->MovePC($zoneid, $jailX - 10, $jailY + 10, $jailZ, $jailW);
			}
			elsif ($random == 5) {
				$client->MovePC($zoneid, $jailX + 10, $jailY + 10, $jailZ, $jailW);
			}
			elsif ($random == 6) {
				$client->MovePC($zoneid, $jailX - 10, $jailY - 10, $jailZ, $jailW);
			}
			my $classplural = "${class}s";
			$client->Message(15, "What we've got here, is a failure to communicate.  Some $classplural you just can't reach.");
			$client->CastSpell(5068, $userid);
		}
	}
}

sub EVENT_EXIT {
	my $random = int(rand(6)) + 1;
	if ($random == 1) {
		$client->MovePC($zoneid, $jailX + 10, $jailY - 10, $jailZ, $jailW);
	}
	elsif ($random == 2) {
		$client->MovePC($zoneid, $jailX - 10, $jailY + 10, $jailZ, $jailW);
	}
	elsif ($random == 3) {
		$client->MovePC($zoneid, $jailX + 10, $jailY - 10, $jailZ, $jailW);
	}
	elsif ($random == 4) {
		$client->MovePC($zoneid, $jailX - 10, $jailY + 10, $jailZ, $jailW);
	}
	elsif ($random == 5) {
		$client->MovePC($zoneid, $jailX + 10, $jailY + 10, $jailZ, $jailW);
	}
	elsif ($random == 6) {
		$client->MovePC($zoneid, $jailX - 10, $jailY - 10, $jailZ, $jailW);
	}
	my $classplural = "${class}s";
	$client->Message(15, "What we've got here, is a failure to communicate.  Some $classplural you just can't reach.");
	$client->CastSpell(5068, $userid);
}
