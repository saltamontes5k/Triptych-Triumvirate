# items: 60173
sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 60173 =>1)) {
    quest::emote("motions for you to enter the altar through the entrance behind him.");
	if ((defined($qglobals{ikky}) && ($qglobals{ikky} >= 14)) || $client->GetGM()) {	
		# Define the expedition name and version
		my $expedition_name = "Ikkinz, Antechamber of Destruction";
		my $dz_version = 6;
		my $dz_duration = 79200;
		my $min_players = 1;
		my $max_players = 54;
		if (plugin::MultiClassingEnabled()){
			$min_players = 1;
			$max_players = 6;
		}

		# Define the expedition information
		my %expedition_info = (
			expedition => {
				name        => $expedition_name,
				min_players => $min_players,
				max_players => $max_players
			},
			instance => {
				zone     => "ikkinz",
				version  => $dz_version,
				duration => $dz_duration
			},
			compass => {
				zone => "kodtaz",
				x    => 1860,
				y    => 660,
				z    => -447
			},
			safereturn => {
				zone => "kodtaz",
				x    => $npc->GetX(),
				y    => $npc->GetY(),
				z    => $npc->GetZ(),
				h    => 0.0
			},
			zonein => {
				x => -157,
				y => 27,
				z => -2,
				h => 0
			}
		);

		my $expedition = $client->CreateExpedition(\%expedition_info);
	}
  }
  quest::summonfixeditem(60173); # Item: Icon of the Altar
}   
