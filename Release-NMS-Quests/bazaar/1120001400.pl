sub EVENT_SAY {
	my $NPCName = $npc->GetCleanName();
	my $languages = quest::saylink("languages", 1);

	if ($text =~ /hail/i) {
		$client->Message(315, "$NPCName whispers to you, 'Good day to you, $name. Would you like to learn to speak all the [$languages] of Norrath?'");
	}

	if ($text =~ /languages/i) {
		if (!defined $qglobals{Language}) {
			for (my $i = 0; $i <= 27; $i++) {
				$client->SetLanguageSkill($i, 100);
			}
			plugin::Whisper("Enjoy your new knowledge of the languages in the land of Norrath!");
			quest::setglobal("Language", "1", "5", "F");
		}
		else {
			plugin::Whisper("You already know all the languages in the land of Norrath!");
		}
	}
}
