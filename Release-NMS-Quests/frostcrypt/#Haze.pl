# Haze - Frostcrypt, Throne of the Shade King
# The Serpent's Spine :: Maze raid event (corner-thing variant).
# Permarooted guardian of one maze corner. When all four fall within minutes of
# each other, the maze itself retaliates: an unleashed icemass (1120002365).

sub EVENT_DEATH {
  quest::set_data('maze_corner_Haze', '1', '600');
  my $c = 0;
  foreach my $k ('Crusher', 'Fleshless', 'Haze', 'Fallow') {
    $c++ if quest::get_data("maze_corner_$k") >= 1;
  }
  if ($c >= 4) {
    quest::ze(15, "The maze shudders as the four guardians fall. Ice groans and rises!");
    my ($x, $y, $z) = ($npc->GetX(), $npc->GetY(), $npc->GetZ());
    quest::unique_spawn(1120002365, 0, 0, $x, $y + 40, $z, 0);
    foreach my $k ('Crusher', 'Fleshless', 'Haze', 'Fallow') {
      quest::set_data("maze_corner_$k", '0');
    }
  }
}
