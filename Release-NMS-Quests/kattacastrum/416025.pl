#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - Arcanist Thalian (416025)
# Tasks: Renegade Servants (620115), Storms of Magic (620116)
# -> Dusty Pottery Piece, Dusty Pottery Chip.
#--------------------------------------------------------------------------
my @order = (620115, 620116);
my %tasks = (
  620115 => ['round', 'The renegade servants grow bold in the dark. [round] them up: darkmuds, elementals of the deep, fire whisperers. Five of each.'],
  620116 => ['project', 'My [next project] needs reagents. Sparkling Coral Dust from the drowned constructs of Thalassius -- ten measures.'],
);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    my $next = -1;
    for my $t (@order) {
      if (!quest::istaskcompleted($t)) { $next = $t; last; }
    }
    if ($next >= 0) {
      quest::say($tasks{$next}[1]);
    } else {
      quest::say("The arcanum is richer for your work, $name. The urn project moves.");
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("The work will not do itself, $name.");
    } else {
      quest::assigntask($tid);
      quest::say("Go. And be precise.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
