sub EVENT_SAY {
    # This functionality is meant only for GMs
    if ($client->GetGM()) {
        if($text=~/Hail/i) {
            quest::say("Usage: add character_name, discord_id, [subscriber_level] - add or replace an account->discord mapping with optional subscriber level");
            quest::say("Usage: set character_name, subscriber_level - set the subscriber level of the specified account");
            quest::say("usage: get character_name - view the subscriber level of the specified account")
        }
    }
}