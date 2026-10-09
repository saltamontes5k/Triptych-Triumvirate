# #Zebuxoruk (465000) -- The Void G. Temporal wares shift with each version.
sub EVENT_SAY {
    $client->Message(15, "Zebuxoruk gestures at the rift-touched wares. Say 'progress' to any task giver for your Seeds of Destruction standings.");
    plugin::SodReport($client);
}
