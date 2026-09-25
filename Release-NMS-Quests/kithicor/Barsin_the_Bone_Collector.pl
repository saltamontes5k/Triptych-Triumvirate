sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("You there! Yes you! You look like the type that isn't scared off easily. I have a few projects that need a few [bones].");
	}
	elsif ($text =~ /bones|projects|list|help/i) {
		if (quest::is_content_flag_enabled('peq_halloween')) {
			quest::say("I need a Splintered Discordling Bone from the Wall of Slaughter, four Bone Chips from the Plane of Nightmare, and Dragon Skull Fragments from the Dragon Necropolis. Bring them to me.");
			quest::assigntask(620009);
		} else {
			quest::say("The bones are quiet... return during the Nights of the Dead.");
		}
	}
}

sub EVENT_ITEM {
	if (plugin::check_handin(\%itemcount, 54349 => 1, 12694 => 4, 84081 => 1)) {
		quest::say("Ah, excellent specimens! Let me see what I can make... wait. What is that? The bones are moving!");
		if (quest::istaskactive(620009)) { quest::updatetaskactivity(620009, 3, 1); }
		quest::spawn2(1500200028, 0, 0, $npc->GetX() + 8, $npc->GetY(), $npc->GetZ(), $npc->GetHeading());
	} else {
		plugin::return_items(\%itemcount);
	}
}
