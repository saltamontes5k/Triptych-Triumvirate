#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - Sorcerer Xycl (416010)
# Tasks: Reacquiring Control (620117), The Incursion (620118),
# Inconsequential Restoration (620119), Exploring the Chambers (620120),
# Cavernous Reconnaissance (620121) -> the Polished Pottery set.
#--------------------------------------------------------------------------
my @order = (620117, 620118, 620119, 620120, 620121);
my %tasks = (
  620117 => ['control', 'The surface of Thalassius slips its leash. [control] must be reacquired: cull the surface dwellers and break the brute that leads them -- the Muckdiver or the Rockcrusher.'],
  620118 => ['incursion', 'The [incursion] spreads. Recover nine kedge artifacts from the temple floors and thin their ranks as you go.'],
  620119 => ['restoration', 'An [inconsequential restoration] -- their word for it, not mine. Sift the refuse piles by the drowned halls for what pages survive, and cull the zone while you walk it.'],
  620120 => ['chambers', 'My instruments need readings from the sunken [chambers]. Walk all six and cull their experimental brood.'],
  620121 => ['reconnaissance', 'Last: a [reconnaissance] of the deep caverns. Something great dens there -- Kraj Lucolupos. Put it down.'],
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
      quest::say("Thalassius remembers your footfalls, $name. The polished work is done.");
    }
    return;
  }
  if ($text=~/what task/i) {
    my $next = -1;
    for my $t (@order) {
      if (!quest::istaskcompleted($t)) { $next = $t; last; }
    }
    if ($next >= 0) {
      quest::say($tasks{$next}[1]);
    } else {
      quest::say("No task remains for you.");
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("The water does not wait, $name.");
    } else {
      quest::assigntask($tid);
      quest::say("Go. The deep keeps its own ledger.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
