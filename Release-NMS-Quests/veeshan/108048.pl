#BeginFile: Phara_Dar.pl
#Quest for Veeshan's Peak - Phara Dar: Proof for Phara Dar
# items: 69316, 69390, 69389, 27261, 69315
sub EVENT_SPAWN {
	quest::setnexthpevent(80);
}

sub EVENT_COMBAT {
	# if phara leaves combat, reset the hp and depop adds
 	if ($combat_state == 0) {
		$npc->SetHP($npc->GetMaxHP());
		quest::depopall(108518);
		quest::setnexthpevent(80);
 	}
}

sub EVENT_HP {
	if($hpevent == 80) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::setnexthpevent(60);
	} elsif($hpevent == 60) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::setnexthpevent(40);
	} elsif($hpevent == 40) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::setnexthpevent(20);
	} elsif($hpevent == 20) {
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
		quest::spawn2(108518, 0, 0, $x, $y, $z, $h); # NPC: #Protector_of_Phara_Dar
	}
}

#END of FILE Zone:veeshan ID:108048 -- Phara_Dar.pl
