# Veeshan's Peak 2.0 - Phara Dar, Queen of the Brood (instance version 100).
# Summons waves of her Protectors as her health falls, mirroring the classic
# encounter but for the revamped instance version.

sub EVENT_SPAWN {
	return if (!defined($instanceversion) || $instanceversion != 100);
	quest::setnexthpevent(80);
}

sub EVENT_COMBAT {
	return if (!defined($instanceversion) || $instanceversion != 100);
	# if phara leaves combat, reset the hp and depop adds
	if ($combat_state == 0) {
		$npc->SetHP($npc->GetMaxHP());
		quest::depopall(108518); # Protector of Phara Dar
		quest::setnexthpevent(80);
	}
}

sub EVENT_HP {
	return if (!defined($instanceversion) || $instanceversion != 100);

	if ($hpevent == 80) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::setnexthpevent(60);
	}
	elsif ($hpevent == 60) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::setnexthpevent(40);
	}
	elsif ($hpevent == 40) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::setnexthpevent(20);
	}
	elsif ($hpevent == 20) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # Protector of Phara Dar
	}
}
