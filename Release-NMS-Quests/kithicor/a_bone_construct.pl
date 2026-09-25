sub EVENT_DEATH {
	my $k = $entity_list->GetClientByID($killer_id);
	if ($k) { $k->UpdateTaskActivity(620009, 4, 1); }
}
