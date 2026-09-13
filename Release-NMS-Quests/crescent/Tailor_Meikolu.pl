# Tailor Meikolu - Crescent Reach (Artisans' Row, second level)
# The Serpent's Spine :: Prove Your Worth (task 600241)
# Hands out the banner materials and finishes the banner from the cloth.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600241, 0)) {
      quest::say("And greetings to you, friend. There has been so much interest and assistance that I'm nearly out of supplies to make banners. I may have enough for you. Take this pattern, dye, and cloth and combine them in the sewing kit I will give you. Then you will have made the basic pattern. Return the banner cloth to me and I will sew it to an old wizened staff which will serve as the banner's pole.");
      quest::updatetaskactivity(600241, 0, 1);
      quest::summonitem(84227); # Drakkin Sewing Kit
      quest::summonitem(84223); # Banner Pattern
      quest::summonitem(84224); # Shimmering Dye
      quest::summonitem(84225); # Bolt of Fine Cloth
    }
    elsif (quest::istaskactive(600241)) {
      quest::say("Combine the pattern, dye and cloth in the Drakkin Sewing Kit I gave you, then bring me the Banner Cloth.");
    }
    else {
      quest::say("Welcome to Artisans' Row. The cloth of Crescent Reach is renowned - or it will be, once we have more than three walls to hang it from.");
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84226 => 1)) { # Banner Cloth
    quest::say("Very well done. Here is the completed banner. You may go and give it to one of the councilmembers to prove your allegiance.");
    quest::summonitem(84230); # Banner of the Drakkin
    if (quest::istaskactivityactive(600241, 2)) {
      quest::updatetaskactivity(600241, 2, 1);
    }
  }
  plugin::return_items(\%itemcount);
}
