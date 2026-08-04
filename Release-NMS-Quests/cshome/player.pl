$zoneid = quest::GetZoneID();

sub EVENT_ZONE {
	$ssfkey = $client->AccountID() . "ssf";
	if (quest::get_data($ssfkey) == "") {
	$client->Disconnect();	
	}
}

sub EVENT_CONNECT {
	$ssfkey = $client->AccountID() . "ssf";
	if (quest::get_data($ssfkey) == "1") {
	plugin::SendToInstance("public", "cshome", 100, 0, 0, 0, "EXP", 604800);
	}
}

sub EVENT_TRADE {
	$ssfkey = $client->AccountID() . "ssf";
	if (quest::get_data($ssfkey) == "1") {
		plugin::SendToInstance("public", "cshome", 100, 0, 0, 0, "EXP", 604800);
	}

}
