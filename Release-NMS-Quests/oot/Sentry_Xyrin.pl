#:: Grid 62 inserts: 
#:: 
#:: INSERT INTO `grid` (`id`, `zoneid`, `type`, `type2`)
#:: VALUES
#::     (62, 69, 6, 1);
#:: INSERT INTO `grid_entries` (`gridid`, `zoneid`, `number`, `x`, `y`, `z`, `heading`, `pause`, `centerpoint`)
#:: VALUES
#::     (62, 69, 1, -7332, -612, 1, -1, 0, 0),
#::     (62, 69, 2, -7219, -687, 82, -1, 0, 0),
#::     (62, 69, 3, -7150, -767, 38, -1, 0, 0),
#::     (62, 69, 4, -7098, -885, 131, -1, 0, 0),
#::     (62, 69, 5, -6963, -886, 139, -1, 20, 0),
#::     (62, 69, 6, -6881, -785, 158, 314, 600, 0);

sub EVENT_SPAWN {
	#:: Set a timer for 1 hour
	quest::settimer("depop", 3600);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Shhhh!! Keep quiet! Can you not tell this island is inhabited by undead? I wish to take the fight to them, but I am weak from the [boat disaster].");
	}
	elsif ($text=~/boat disaster/i) {
		quest::say("I was returning to my temple in Freeport in a small boat when the storm hit. I soon found myself shipwrecked on this evil island of undead. The words of Marr tell me to destroy these beings, but I am far too weak. If I only had a sip of the [Potion of Marr].");
	}
	elsif ($text=~/potion of marr/i) {
		quest::say("The Potion of Marr was created for the Sentries of Passion. It makes us alert and energetic. It will work only on sentries such as myself. It is distributed by Serna Tasknon of the Temple of Marr in Freeport.");
	}			
}

sub EVENT_WAYPOINT_ARRIVE {
	if ($wp == 4) {
		quest::shout("Long live Marr!!");
		#:: Hate on the undead
		KillUndead();
	}
	elsif ($wp == 5) {
		quest::say("Many thanks to all who aided in this battle. I offer you this, a weapon I found on a slain Erudite paladin. May Marr watch over his soul and may Marr guide yours. Now I must go.");
		#:: Ground spawn a 5414 - Deepwater Harpoon at the current location
 		quest::creategroundobject(2005414, $x, $y, $z, 0, 1800000);
		#:: Depop
		quest::depop();			
	}
}

sub EVENT_COMBAT {
	#:: Match combat state 1 - entered combat
	if ($combat_state == 1) {
		quest::say("Let the fury of passion smite thee!");
	}
}

sub EVENT_TIMER {
	#:: Match timer named "depop"
	if ($timer eq "depop") {
		#:: Depop
		quest::depop();
	}
}

sub EVENT_ITEM {
	#:: Match a 12134 - Last of Potion of Marr
	if (plugin::check_handin(\%itemcount, 12134 => 1)) {
		quest::say("Ahhhh! I am energized! Come! Let us show these undead the greatness of Erollisi Marr!");
		#:: give a 12135 - Empty Potion of Marr
		quest::summonitem(12135);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(362, 1);		#:: + Priests of Marr
		quest::faction(330, -1);	#:: - Freeport Militia
		quest::faction(281, 1);		#:: + Knights of Truth
		#:: Set running to true
		quest::SetRunning(1);
		#:: Start pathing grid 62
		quest::start(62);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub KillUndead {
	#:: Create an array of the NPC entities in the zone
	my @npc_list = $entity_list->GetNPCList();
	#:: For each member of the list...
	foreach $npc_ent (@npc_list) {
		#:: Select any spectres and skeletons within 1000 units
		if ($npc_ent->CalculateDistance($x, $y, $z) < 1000 && $npc_ent->GetCleanName()=~/spectre/i || $npc_ent->GetCleanName()=~/skeleton/i) {
			#:: Attack the selected entity
			$npc->Attack($npc_ent);
			#:: Exit the loop after the first match
			last;
		}
	}
}
