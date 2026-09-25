#--------------------------------------------------------------------------
# TBS: Noble Phren - Jewel of Atiiki (#Noble_Phren 418047)
# Reads the Platinum Efreeti inscriptions and explains the game of order
# during the Efreeti Death Visage task (620075).
#--------------------------------------------------------------------------
sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(620075) || quest::istaskcompleted(620075)) {
      quest::say("Ah, Platinum Efreeti armor. Each piece bears an inscription, and together they describe a board of order. Azia looks to the west and sees Izah in the distance; Kala opposes Geza from his corner; Caza is ringed by seven allies; Lena avoids the perimeter while Jaka does not; Meda stands neither east nor west; and Geza stands directly east of Jaka. The wisdom of Ateleka guides those who seek knowledge. Take the Token of Order, set the board at Mahatototarit, and say 'done' when the pieces align.");
    } else {
      quest::say("The efreeti keep their secrets in their armor. Speak with Noble Sivrn if you would learn them.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
