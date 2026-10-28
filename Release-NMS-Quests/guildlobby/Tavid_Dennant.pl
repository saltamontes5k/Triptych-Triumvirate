# Tavid Dennant - Guild Lobby
# "Consigned Items from Tavid Dennant" (DoN armor luminessence system).
# Hands out one free Consigned item of each type per character; anything
# handed back is returned. Items: Consigned band 42941-42960.
#   42942 Luminescent Culling Vortex   42943 Incandescent Culling Vortex
#   42960 Temporal Polymorphic Cell    42941 Temporal Molting Cell
#   42944-42959 Consigned <Class>'s Polymorphic Cocoon (class-mapped)

sub _tavid_give {
  my ($client, $itemid, $label) = @_;
  my $name = $client->GetCleanName();
  my $key = 'tavid-gave-' . $itemid;
  if (int($client->GetBucket($key) || 0)) {
    plugin::Whisper("I have already given you that, $name. My stock is limited -- find someone who needs it more.");
    return;
  }
  $client->SetBucket($key, 1);
  $client->SummonItem($itemid, 1);
  plugin::Whisper("Here you are, $name -- $label. Treat it well; I won't have another for you.");
}

sub EVENT_SAY {
  my $name = $client->GetCleanName();
  if($text=~/hail/i) {
    quest::say("Well hello! What brings a traveler like you to a place like this? Me? I seem to have misplaced my scarf, I don't suppose you've seen it? Long, wool, colorful? I can't imagine where I might have left it. Speaking of misplaced things, I've got quite a number of who's its and what's its that I've picked up during my travels. You're welcome to take a look if you think you might find any of it useful. All except for this [watch] of course. I also have a limited amount of [items] that work with armor from beyond the void. These I will even give for free, but you must ask me for them.");
  } elsif($text=~/luminescent/i) {
    _tavid_give($client, 42942, "Consigned Luminescent Culling Vortex");
  } elsif($text=~/incandescent/i) {
    _tavid_give($client, 42943, "Consigned Incandescent Culling Vortex");
  } elsif($text=~/polymorphic cell|cells/i) {
    _tavid_give($client, 42960, "Consigned Temporal Polymorphic Cell");
  } elsif($text=~/molting/i) {
    _tavid_give($client, 42941, "Consigned Temporal Molting Cell");
  } elsif($text=~/cocoon/i) {
    my %cocoon = (
      1 => 42944, 2 => 42945, 3 => 42946, 4 => 42947,
      5 => 42948, 6 => 42949, 7 => 42950, 8 => 42951,
      9 => 42952, 10 => 42953, 11 => 42954, 12 => 42955,
      13 => 42956, 14 => 42957, 15 => 42958, 16 => 42959,
    );
    my $id = $cocoon{$client->GetClass()};
    if ($id) {
      _tavid_give($client, $id, "your class's Consigned Polymorphic Cocoon");
    } else {
      plugin::Whisper("Cocoons are bound to a calling, $name. Come back as one of the sixteen and we'll talk.");
      plugin::return_items(\%itemcount);
    }
  } elsif($text=~/items/i) {
    my $lum = quest::saylink("luminescent", 1, "luminescent");
    my $inc = quest::saylink("incandescent", 1, "incandescent");
    my $cell = quest::saylink("polymorphic cell", 1, "polymorphic cell");
    my $molt = quest::saylink("molting", 1, "molting");
    my $coc = quest::saylink("cocoon", 1, "cocoon");
    quest::say("I can offer you a $lum culling vortex or an $inc one, a $cell, or a $molt cell. And if you carry a suit of armor from beyond the void, a $coc bound to your calling. The vortexes will remove a luminessence or incandessence from armor; a polymorphic cell will transform one into the other; the molting cell and cocoon will use them to empower armor. If you get something you do not wish, just give it back to me. One of each, mind you -- my stock is limited.");
  } elsif($text=~/watch/i) {
    quest::say("I can remember where I found all of these other things, but the watch I just seem to have always had. I couldn't part with it, so don't ask.");
  } elsif($text=~/doctor/i) {
    quest::say("Doctor? No, I think you must have me confused with someone else. I've never even been to a place called... wherever that was.");
  }
}

sub EVENT_ITEM {
  # Anything handed back (an unwanted Consigned item, or otherwise) is returned.
  plugin::return_items(\%itemcount);
}
