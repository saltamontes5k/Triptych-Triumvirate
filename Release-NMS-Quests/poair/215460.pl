sub EVENT_DEATH_COMPLETE {
	my $counter = $npc->GetEntityVariable("counter");
	if($counter == "") {
		$counter = 0;
	}

	if($counter >= 10) {
		return;
	}

	$counter = $counter + 1;

	my $id = quest::spawn2(215460,0,0,$x,$y,$z,$h); # NPC: an_erratic_arachnid
	if($id) {
		my $new_mob = $entity_list->GetMobByID($id);
		if($new_mob) {
			$new_mob->SetEntityVariable("counter", $counter);
		}
	}
}
