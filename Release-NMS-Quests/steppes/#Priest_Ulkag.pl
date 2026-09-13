# Priest Ulkag - The Steppes
# The Serpent's Spine :: Duskmold (task 600112)
# Items: Doomshriek Mushroom 36157, Twittering Fungus Cap 36156, Orb of Duskmold 53651

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("I desperately require the roots from the two species of Duskmold fungi. Igantug has very little time. Will you journey into the depths of the Vergalid Mines and bring back samples?");
  }
  if ($text=~/fungus/i || $text=~/duskmold/i) {
    if (!quest::istaskactive(600112) && !quest::istaskcompleted(600112)) {
      quest::say("Hack apart the sturdy stalks of the Doomshriek and the Twittering fungi. Bring me their roots, and I may yet save Igantug.");
      quest::assigntask(600112);
    }
    else {
      quest::say("The fungi still stand in the Vergalid Mines. Bring me their roots.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
