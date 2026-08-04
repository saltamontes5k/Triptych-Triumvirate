#Just a little flavor for when XTC kills someone.

sub EVENT_SLAY {
  quest::say("Odd, we normally have to drag sacrifices kicking and screaming, but this one all but throws himself at us.");
}

sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, 256, 193, 252, $entity_list);
}

sub EVENT_KILLED_MERIT {
    plugin::handle_killed_merit($npc, $client, $entity_list);
}