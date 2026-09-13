# a_book_on_a_table - Crescent Reach (library)
# The Serpent's Spine :: Getting to Know You: The City Charter (task 505746)
# Hands out a copy of the City Charter (57974).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(505746, 1) && !$client->CountItem(57974)) {
      quest::say("You pull the city charter from the bookshelf.");
      quest::emote("crackles as the old binding falls open in your hands.");
      quest::summonitem(57974); # Crescent Reach City Charter
      quest::updatetaskactivity(505746, 1, 1);
    }
    else {
      quest::say("Rows upon rows of charter copies. My staff just finished scribing a new set.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
