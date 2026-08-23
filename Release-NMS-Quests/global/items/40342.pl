sub EVENT_SCALE_CALC {
	#:: Used for charms that scale with number of rare languages learned
	my $langmastered = 0;
 
	#:: Check each rare language: Old Erudian through Elder Dragon
	for (my $i = 11; $i <= 22; $i++) {
		#:: Check if the client has mastered the language
		if ($client->GetLanguageSkill($i) == 100) {
			$langmastered++;
		}
	}
	$itemid->SetScale($langmastered/12);
}
