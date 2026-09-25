#--------------------------------------------------------------------------
# TBS: Mahatototarit - Jewel of Atiiki (418091)
# Hosts the game of order. When a player with the full Platinum Efreeti set,
# the mask (79507) and the Token of Order (79508) says "done", summons Paza.
#--------------------------------------------------------------------------
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("A game of order? The board is set, but the pieces obey no simple rule.");
    return;
  }

  if ($text=~/done/i) {
    if (!quest::istaskactive(620075) && !quest::istaskcompleted(620075)) {
      quest::say("You have no business with this board.");
      return;
    }
    my $ok = plugin::check_hasitem($client, 79507) && plugin::check_hasitem($client, 79508);
    for my $i (79500 .. 79506) {
      $ok = 0 if !plugin::check_hasitem($client, $i);
    }
    if (!$ok) {
      quest::say("You do not carry the full set of Platinum Efreeti armor, its mask, and the Token of Order. Return when you do.");
      return;
    }
    if (plugin::check_hasitem($client, 79515)) {
      quest::say("You already bear the visage. There is nothing more I can show you.");
      return;
    }
    quest::say("A very interesting configuration... you have not exactly solved the puzzle, but you have unlocked a pattern that summons our lost Paza from the realm of the dead!");
    quest::spawn2(423914, 0, 0, 1085.0, -392.0, 5.125, 0);
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
