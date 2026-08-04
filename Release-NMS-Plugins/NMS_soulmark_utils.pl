# NMS_soulmark_utils.pl
# Contains utilities for handling the Soulmark (CheaterFlag) system.

sub GetSoulmark {
    my $client = shift;
    
    if (!$client) {
        return undef;
    }

    my $account_id = $client->AccountID();
    my $key = $account_id . "-CheaterFlag";
    
    my $reason = quest::get_data($key);
    
    if (defined $reason && $reason ne "") {
        return $reason;
    }
    
    return undef;
}

sub DisplayWarning {
    my $client = shift;

    if (!$client) {
        return;
    }

    my $reason = plugin::GetSoulmark($client);

    if ($reason) {
        # Display an unignorable red warning to the player
        $client->Message(13, "==================================================");
        $client->Message(13, "WARNING: This account has received a Soulmark for violations of server rules.");
        $client->Message(13, "Reason: " . $reason);
        $client->Message(13, "Further infractions will result in permanent account termination.");
        $client->Message(13, "==================================================");
    }
}
