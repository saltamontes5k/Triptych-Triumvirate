# Master_of_Games (1120002560) -- Bazaar arcade host.
#
# Lists every arcade game as a clickable say-link; clicking one opens its NMS
# window. EVENT_TIMER drives the shared 20-tick game clock, EVENT_NMS_WINDOW
# routes window input back into the library. Engine: zone/nms_window.h
# (server) + eqgame_dll/nms_window.cpp (client). Spawn: migration 312.
#
# Games load from the plugins tree (plugin::arcade_load resolves
# plugin/arcade_game_<name>.pl); the library itself is plugins/NMS_arcade.pl.

sub EVENT_SAY {
	# arcade_npc starts a game when $text matches a game name, otherwise it
	# lists everything as clickable say-links (so "hail" and "games" both list)
	plugin::arcade_npc($npc, $client, $text, {
		coin_flip   => plugin::arcade_load("coin_flip"),
		tic_tac_toe => plugin::arcade_load("tic_tac_toe"),
		snake       => plugin::arcade_load("snake"),
		blackjack   => plugin::arcade_load("blackjack"),
		my_stats    => plugin::arcade_load("my_stats"),
	});
}

sub EVENT_TIMER {
	plugin::arcade_on_timer($npc) if $timer eq "arcade";
}

sub EVENT_NMS_WINDOW {
	plugin::arcade_on_window($client, {
		window_id => $nms_window_id,
		kind      => $nms_kind,
		action    => $nms_action,
		value     => $nms_value,
		text      => $nms_text,
	});
}
