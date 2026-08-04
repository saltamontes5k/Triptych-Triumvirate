my $LockoutTime = 345600;
my @Data = ("hateplane", 76, -353, -375, 4, 0);

sub EVENT_SAY {
	$raid = $client->GetRaid();
	if (!$raid) {
		$client->Message(15, "Agent of Change says, 'I would speak to the leader of your raid, $name.'");
	}
	elsif ($ulevel < 46) {
		$client->Message(15, "Agent of Change says, 'Go away little one.  Return when you have more experience.'");
	}
	elsif ($text=~/hail/i) {
		$key = $name . "-" . $Data[0];
		if (!quest::get_data($key)) {
			if ($raid->IsLeader($name)) {
				$client->Message(15, "Agent of Change says, 'Hello, $name.  Would you like to [create] an instance?'");
			}
			else {
				$client->Message(15, "Agent of Change says, 'I would speak to the leader of your raid, $name.'");
			}
		}
		else {
			my $LockoutTime = quest::get_data_expires($key) - time();
			$client->Message(15, "Agent of Change says, 'You have instance " . quest::get_data($key) . ", $name.  It will expire in $LockoutTime seconds.  Let me know if you are [ready] to return to your instance.'");
		}
	}
	elsif ($text=~/create/i) {
		$key = $Data[0] . "-lockout";
		if (!quest::get_data($key)) {
			if ($raid->IsLeader($name)) {
				$key = $name . "-" . $Data[0];
				if (!quest::get_data($key)) {
					$Instance = quest::CreateInstance("$Data[0]", 0, $LockoutTime);
					quest::set_data($key, $Instance, $LockoutTime);
					$key = $raid->GetID() . "-" . $Data[0];
					quest::set_data($key, $Instance, $LockoutTime);
					$key = $Data[0] . "-lockout";
					quest::set_data($key, "1", 3600);
					$client->AssignToInstance($Instance);
					$client->Message(15, "Agent of Change says, 'Your instance has been created. Have your raid let me know when they are [ready].'");
				}
				else {
					my $LockoutTime = quest::get_data_expires($key) - time();
					$client->Message(15, "Agent of Change says, 'You have instance " . quest::get_data($key) . ", $name.  It will expire in $LockoutTime seconds.  Let me know if you are [ready] to return to your instance.'");
				}
			}
			else {
				$client->Message(15, "Agent of Change says, 'I would speak to the leader of your raid, $name.'");
			}
		}
		else {
			my $LockoutTime = int((quest::get_data_expires($key) - time())/60);
			if ($LockoutTime > 1) {
				$client->Message(15, "Agent of Change says, 'I do not have the energy to create a new instance yet, $name.  I must rest for another $LockoutTime minutes.'");
			}
			else {
				$client->Message(15, "Agent of Change says, 'I will be able to create an instance soon, $name.'");
			}
		}
	}
	elsif ($text=~/ready/i) {
		$key = $raid->GetID() . "-" . $Data[0];
		if (!quest::get_data($key)) {
			$client->Message(15, "Agent of Change says, 'I would speak to the leader of your raid, $name.'");
		}
		else {
			$Instance = quest::get_data($key);
			$key = $name . "-" . $Data[0];
			if (!quest::get_data($key)) {
				if (quest::GetInstanceTimerByID($Instance) > 0) {
					quest::set_data($key, $Instance, $LockoutTime);
					$client->AssignToInstance($Instance);
					$client->Message(15, "Agent of Change says, 'Moving you to Zone: $Data[0], Instance: $Instance.'");
					$client->MovePCInstance($Data[1], $Instance, $Data[2], $Data[3], $Data[4], $Data[5]);
				}
				else {
					$client->Message(15, "Agent of Change says, 'That instance has expired, $name.'");
				}
			}
			else {
				if ($Instance == quest::get_data($key)) {
					if (quest::GetInstanceTimerByID($Instance) > 0) {
						$client->Message(15, "Agent of Change says, 'Moving you to Zone: $Data[0], Instance: $Instance.'");
						$client->MovePCInstance($Data[1], $Instance, $Data[2], $Data[3], $Data[4], $Data[5]);
					}
					else {
						$client->Message(15, "Agent of Change says, 'That instance has expired, $name.'");
					}
				}
				else {
					my $LockoutTime = quest::get_data_expires($key) - time();
					$client->Message(15, "Agent of Change says, 'You must wait for instance " . quest::get_data($key) . "to expire, $name.  It will expire in $LockoutTime seconds.'");
				}
			}
		}
	}
}
