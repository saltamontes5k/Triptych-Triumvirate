# Councilmember Heshyrr - Crescent Reach
# The Serpent's Spine :: Heshyrr's Wisdom (task 600242)
# Gate: Prove Your Worth (600241). Gives Seeker's Spiritstaff (84221),
# requires speaking with Spirit of Truth, Spirit of Wisdom and Yuvill.
# Also accepts the Banner of the Drakkin (84230) for Prove Your Worth.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600241)) {
      quest::say("I'm afraid we are too busy to speak to those who are unfamiliar with our customs. Perhaps speak to Council Aide Mystrana and prove yourself first.");
    }
    elsif (!quest::istaskcompleted(600242) && !quest::istaskactive(600242)) {
      quest::say("Vasha. I am Heshyrr, first child of Lady Mysaphar, she of the Moonfire. You have proven your worth to the city, and so I will teach you a little of the [" . quest::saylink("spirit world") . "].");
    }
    elsif (quest::istaskactive(600242)) {
      quest::say("Listen for the spirits, friend. The [" . quest::saylink("truth") . "] and the [" . quest::saylink("wisdom") . "] wait among the rune stones, and the spirithunter walks unseen on the third level of the city.");
    }
    else {
      quest::say("May the Moonfire light your path, friend.");
    }
  }
  if ($text=~/spirit world/i) {
    quest::say("The spirits of the past yet linger in this fallen ogre city. If you [" . quest::saylink("wish") . "], you may learn what they have to teach - though most are blind to them.");
  }
  if ($text=~/wish/i) {
    quest::say("Then hear me. At the rune stones in the Dragon's Grove waits a Spirit of Truth. East of the tunnel to the city, at the rune stones there, waits a Spirit of Wisdom. Hear them both, then find me again.");
    quest::say("Take this spiritstaff so that the spirits shall sense your presence.");
    quest::summonitem(84221); # Seeker's Spiritstaff
    quest::assigntask(600242); # Heshyrr's Wisdom
  }
  if ($text=~/truth/i) {
    quest::say("The Spirit of Truth waits at the rune stones in the southwest of the Dragon's Grove. It will know you by the spiritstaff you carry.");
  }
  if ($text=~/wisdom/i) {
    quest::say("The Spirit of Wisdom waits at the rune stones east of the tunnel that leads into the city. Hear what it has to say of the past.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 84230 => 1)) { # Banner of the Drakkin
    quest::say("Karu dra, this is a most fine banner indeed. The stitching is very refined. We will have this banner placed in the city.");
    if (quest::istaskactivityactive(600241, 3)) {
      quest::updatetaskactivity(600241, 3, 1);
    }
    quest::faction(1129, 10); # Circle of the Crystalwing
  }
  plugin::return_items(\%itemcount);
}
