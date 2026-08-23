sub EVENT_SAY {
	quest::debug("bucket: " . $npc->GetBucket("Tolon_Nurbyte"));
    if ($text=~/tolon nurbyte/i && !$npc->GetBucket("Tolon_Nurbyte")) {
        quest::say("So you are inquiring about Mister Tolon Nurbyte, eh? He is on the second floor, last door on the right. You two had best not be up to any mischief. The pair of you look a little shifty for the kingdom of Felwithe.");
        #:: Spawn one and only one Northern Felwithe >> Tolon_Nurbyte (61095), without guild war or pathing grid, at the specified location
        quest::unique_spawn(61095, 0, 0, -343, 155, 17, 8);
        $npc->SetBucket("Tolon_Nurbyte", 1, "10m");
    }
}