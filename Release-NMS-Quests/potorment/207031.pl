##An_Unimaginable_Horror (207031)

sub EVENT_DEATH_COMPLETE {
	quest::signalwith(207028,1);
	quest::spawn2(207082,0,0,1,-1021,-27,0); #Real #Baraguj_Szuul
	my @clientlist = $entity_list->GetClientList();
	foreach $ent (@clientlist) {
		#distance restriction so the members need to be reasonably close.
		if ($ent->CalculateDistance($npc->GetX(),$npc->GetY(),$npc->GetZ()) <= 200) {
		$ent->MovePCInstance(207,$instanceid, 1,-890,-27,360); #back to Baraguj_Szuul
		}
	}
}
