my $emarr_sign = 36845;

sub EVENT_SPELL_EFFECT_CLIENT {
    my $base_add = 30 * 60; # 30 minutes in seconds

    my $expiration_time = quest::add_global_buff($emarr_sign, $base_add);
    my $remaining_seconds = $expiration_time - time();

    # Calculate hours and minutes for both the extension and total remaining time
    my $add_hours   = int($base_add / 3600);
    my $add_minutes = int(($base_add % 3600) / 60);
    my $total_hours = int($remaining_seconds / 3600);
    my $total_minutes = int(($remaining_seconds % 3600) / 60);

    # Format extension time message
    my $add_time_str = "";
    $add_time_str .= "$add_hours Hours " if $add_hours > 0;
    $add_time_str .= "$add_minutes Minutes";

    # Format total time message
    my $total_time_str = "";
    $total_time_str .= "$total_hours Hours " if $total_hours > 0;
    $total_time_str .= "$total_minutes Minutes";

    plugin::WorldAnnounce($client->GetCleanName() .
        " has used their Signet of Erollosi's Love, extending their blessing by $add_time_str, " .
        "for a total buff duration of $total_time_str.");

    quest::reload_global_buffs();
}
