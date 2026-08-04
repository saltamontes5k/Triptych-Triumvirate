sub EVENT_SAY {
    if ($faction <= 5) {
        if ($text=~/hail/i) {
            $client->Message(0, "Oi, what is this? A " . $client->GetRace() . ", if my tired old eyes are not mistaken...");
        }
        elsif ($text=~/flood/i) {
            $client->Message(0, "The flood of beings to Velious. Starts with a trickle, like all floods...");
        }
        elsif ($text=~/around/i) {
            $client->Message(0, "I will be leaving this world soon enough, I think...");
        }
        elsif ($text=~/free/i) {
            $client->Message(0, "Dragons have never been truly free...");
        }
        elsif ($text=~/long past/i) {
            $client->Message(0, "It proves how weak and static our race has become...");
        }
        elsif ($text=~/shackles/i) {
            $client->Message(0, "I do not see this happening. Too proud, too sure of ourselves...");
        }
        elsif ($text=~/kromzek/i) {
            $client->Message(0, "The Kromzek are also clinging to the old ways...");
        }
        elsif ($text=~/coldain/i) {
            $client->Message(0, "I admire the Coldain. They are strong because they adapt...");
        }
    }
}

sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
    my $killer = $entity_list->GetClientByID($killer_id);   

    if ($killer && int(rand(100)) == 0) {
        plugin::AddTitleFlag(200);
    }
}
