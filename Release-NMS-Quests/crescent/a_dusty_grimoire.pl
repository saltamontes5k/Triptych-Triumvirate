# a_dusty_grimoire - Crescent Reach (Gekkdar's Haunt, third level)
# The Serpent's Spine :: Getting to Know You: For Those Gone Before Us
# (task 600240). The hidden-room book "The Ogres Come of Age" (57975).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600240, 0) && !$client->CountItem(57975)) {
      quest::say("Behind the hanging curtain, a crate hides a heavy book. You brush off the dust: 'The Ogres Come of Age.'");
      quest::emote("smells of stone dust and old smoke.");
      quest::summonitem(57975); # The Ogres Come of Age
      quest::updatetaskactivity(600240, 0, 1);
    }
    else {
      quest::say("A dusty tome sits on a crate, half-hidden by the curtain.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
