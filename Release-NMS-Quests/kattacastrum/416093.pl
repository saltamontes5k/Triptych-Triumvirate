#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - #Chief_Librarian_Lars
# (416093). Tasks: Retrieving the Lost Knowledge (620124), Zhisza Cypher
# (620125) -> the Worn Pottery Piece and Worn Pottery Splinter.
#--------------------------------------------------------------------------
my @order = (620124, 620125);
my %tasks = (
  620124 => ['analyze', 'The temples of Zhisza drowned with their librarians. [analyze] what survived: the Treaty and the History, from the temple grounds, plus whatever Combine tomes the shissar have not shredded.'],
  620125 => ['books', 'One more, and the shelf is whole: both halves of the [books] -- the Zhisza Cypher, split between patroller and deathcaller.'],
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
      quest::say("The recovered shelf is cataloged, $name. History keeps better company now.");
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("Handle the volumes gently, $name. They are the last of their kind.");
    } else {
      quest::assigntask($tid);
      quest::say("Go. And do not read them in the rain.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
