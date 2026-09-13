# Triune of Fate Custom Currency Plugin
# Alternate Currency ID: 6 (Maps to Item ID: 46779)

sub SpendTriuneOfFate {
    my $client = shift;
    my $amount = shift;
    if ($client) {
        return $client->RemoveAlternateCurrencyValue(6, $amount);
    }
    return 0;
}

sub GetTriuneOfFate {
    my $client = shift;
    if ($client) {
        return $client->GetAlternateCurrencyValue(6);
    }
    return 0;
}

sub TriuneOfFateLink {
    return quest::varlink(46779);
}

sub ApplyWorldWideBuff {
    my $spell_id = shift;
    my $duration = shift || 14400; # Default to 4 hours (14400 seconds)
    
    # Set/extend the global buff time via native C++ quest API
    my $expiration = quest::add_global_buff($spell_id, $duration);
    
    # Broadcast the blessing activation/extension to the world
    my $spell_name = quest::getspellname($spell_id);
    my $remaining_seconds = $expiration - time();
    
    if ($remaining_seconds > 0) {
        my $hours = int($remaining_seconds / 3600);
        my $minutes = int(($remaining_seconds % 3600) / 60);
        
        my $time_str = "";
        $time_str .= "$hours hours " if $hours > 0;
        $time_str .= "$minutes minutes" if $minutes > 0;
        $time_str =~ s/\s+$//; # Clean up trailing space if no minutes
        
        plugin::WorldAnnounce("A server-wide blessing of [$spell_name] has been activated/extended! Remaining duration: $time_str.");
    }
    
    # Force reload of global buffs across all zones
    quest::reload_global_buffs();
    
    return 1;
}

1;
