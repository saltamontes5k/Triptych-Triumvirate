#--------------------------------------------------------------------------
# TBS Katta Castrum - Tsaph Katta's Urn tasks - Alchemist Hesia (416003)
# Task: Herb Retrieval (620112) -> Dusty Pottery Shard.
#--------------------------------------------------------------------------
my %tasks = (
  620112 => ['retrieve', 'The shissar gardeners grow rare things in their steaming beds. [retrieve] four of them for me, and mind the snare-spit.'],
);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted(620112)) {
      quest::say("The herbs you brought have already been ground into the sealant base. The Castrum remembers, $name.");
    } elsif (quest::istaskactive(620112)) {
      quest::say("Four herbs, $name. The gardeners drop them when they fall.");
    } else {
      quest::say("You smell of the deep halls, not the gardens. Good. I need a steady hand to [retrieve] what grows there.");
    }
    return;
  }
  if ($text=~/retrieve/i) {
    if (quest::istaskcompleted(620112)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive(620112)) {
      quest::say("Four herbs. The gardeners and alchemists carry them.");
    } else {
      quest::assigntask(620112);
      quest::say("Go then. Do not crush the leaves.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
