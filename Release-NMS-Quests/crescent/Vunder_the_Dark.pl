# Vunder the Dark - Crescent Reach (top level)
# The Serpent's Spine :: A Dark Heart (task 600252, level 10+)
# Kill Apothecary Shelga, loot her pouch, return it. Reward is the
# class-appropriate Staff of the Dark Apprentice.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600252) && !quest::istaskactive(600252)) {
      quest::say("Yes? What is it? By the looks of you I'd say you would not be interested or committed enough to [learn] anything I could teach you.");
    }
    elsif (quest::istaskactive(600252)) {
      quest::say("The apothecary. Her pouch. Before the warders catch you at it. Go.");
    }
    else {
      quest::say("Yes, yes. The dark arts proceed apace. Move along.");
    }
  }
  if ($text=~/learn/i) {
    quest::say("If you insist, I will tell you what it is I am doing. As a child of Draton`ra, it is my intention to become a master of shadow and necromancy. I will soon surpass the moniker of apprentice and become a very powerful citizen of Crescent Reach and perhaps even replace Vakk`dra on the council of the Scions of the Six. If you're interested in the ways of the dark arts, I could give you a task that gives you a [sample] of the type of spirit and disposition that is required.");
  }
  if ($text=~/sample/i) {
    quest::say("There is a scaleless barbarian that intends to train the drakkin. She has some items and ingredients on her that I need for my studies. You are going to have to [kill] her. There is no other way she will surrender the ingredients. She is in Artisan's Row on the second level of the city. You will need to be sure to kill her before the guards who patrol nearby catch you. They will not look upon a death within the city walls fondly. Then, take her bag of goods and return them to me.");
    quest::assigntask(600252); # A Dark Heart
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 52636 => 1)) { # Shelga's Pouch of Ingredients
    quest::emote("paws through the pouch with evident satisfaction.");
    quest::say("Excellent. Just excellent. These, combined with the rest, will make a fine beginning. Here - I have no further use for you, so take this staff. Consider it your tuition refund.");
    # Activity 2 is the final step; hand out the class-appropriate staff.
    if (quest::istaskactivityactive(600252, 2)) {
      quest::updatetaskactivity(600252, 2, 1);
      my $class = $client->GetClass();
      if ($class == 1 || $class == 2 || $class == 3 || $class == 4 || $class == 5
        || $class == 6 || $class == 7 || $class == 15 || $class == 16) {
        quest::summonitem(54724); # Great Staff of the Dark Apprentice (melee)
      }
      else {
        quest::summonitem(53494); # Staff of the Dark Apprentice (casters)
      }
    }
    return;
  }
  plugin::return_items(\%itemcount);
}
