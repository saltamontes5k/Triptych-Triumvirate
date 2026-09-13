# Smithy Bronson - Crescent Reach
# The Serpent's Spine :: smithing supply quests (tasks 600070-600072)
# Items: Rock Breaker Hammer 85727, Mucktail Mining Pick 36162, Hunk of Brightfire Ore 600160, Hedge Devil Branch 36197

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Smithy Bronson pauses mid swing, his hammer in the air. 'And what can I do for you? Be quick! I am far behind in filling my orders. Or perhaps you've been sent here to [" . quest::saylink("help") . "] me out?'");
  }
  if ($text=~/help/i) {
    quest::say("Are you daft or do you like repeating what has already been said? Don't answer that. As you can see, the rate at which this city is growing is drowning me in orders. Here is a quick list of things I could use a hand with: [" . quest::saylink("gnollish tools") . "], [" . quest::saylink("ore for smelting") . "], or [" . quest::saylink("kindling") . "].");
  }
  if ($text=~/gnollish tools/i) {
    if (!quest::istaskactive(600070) && !quest::istaskcompleted(600070)) {
      quest::say("A bunch of Mucktail gnolls in the Moors stole good tools from us. Bring me back four rock breaker hammers and four mining picks and I'll make it worth your while.");
      quest::assigntask(600070);
    }
    else {
      quest::say("Four rock breaker hammers and four mining picks, got it?");
    }
  }
  if ($text=~/ore for smelting/i) {
    if (!quest::istaskactive(600071) && !quest::istaskcompleted(600071)) {
      quest::say("I need ore for smelting. The Mucktails hoard hunks of brightfire ore. Kill them and bring me four hunks.");
      quest::assigntask(600071);
    }
    else {
      quest::say("Four hunks of brightfire ore, friend.");
    }
  }
  if ($text=~/kindling/i) {
    if (!quest::istaskactive(600072) && !quest::istaskcompleted(600072)) {
      quest::say("My forge is going cold. The hedge devils in the Moors drop branches that burn hot. Bring me four.");
      quest::assigntask(600072);
    }
    else {
      quest::say("Four hedge devil branches, if you please.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
