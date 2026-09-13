# Wraithguard Lorekeeper Fenegar - Valdeholm
# The Serpent's Spine :: Ancient Tomes (task 600214)
# Items: Torn Pages 88180-88183, Tattered Scrolls 88184-88186, Bundle of Brittle Parchment 88187-88188,
#         Empty Book 88189, reward Runed Diamond 53713

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello there. I have heard about the assistance you have given the Wraithguard. What can I do for you, tiny one? Or perhaps you can [" . quest::saylink("do something") . "] for me.");
  }
  if ($text=~/do something/i) {
    quest::say("I have been tasked with evaluating information and items to see if they are of value to our people. Currently I seek information from within the crypts. Perhaps you can [" . quest::saylink("help") . "] me with that.");
  }
  if ($text=~/^help$/i || $text=~/lost tomes/i) {
    if (!quest::istaskactive(600214) && !quest::istaskcompleted(600214)) {
      quest::say("I never found complete books, but there are many pages of ancient Krithgor text that can still be recovered. Find them and return them to me bound carefully in an empty book, and I may find a way to reward you.");
      quest::assigntask(600214);
    }
    else {
      quest::say("Seek the torn pages, tattered scrolls, and brittle parchment of the ancient Krithgor, and bind them in an empty book.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
