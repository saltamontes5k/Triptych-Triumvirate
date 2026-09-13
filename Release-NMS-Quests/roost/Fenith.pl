# Fenith - Blackfeather Roost
# The Serpent's Spine :: griffon taming (task 600040 Blackfeather Roost, The Ledge)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600040)) {
      quest::say("Huh? You want to learn to ride the griffons of the Roost? It takes a [" . quest::saylink("treat") . "], and a steady hand. Feed one and see if it likes you.");
    }
    else {
      quest::say("So you managed to feed the griffon and keep all your fingers? Huh! Well, each griffon likes a different treat. Ask me for a [" . quest::saylink("hint") . "] if you like.");
    }
  }
  if ($text=~/treat/i) {
    if (!quest::istaskactive(600040) && !quest::istaskcompleted(600040)) {
      quest::say("Combine the components in the treat kit, then give the treat to a tame griffon nearby. Mind your fingers!");
      quest::assigntask(600040);
    }
  }
  if ($text=~/hint/i) {
    quest::say("The next griffon has a taste for something found closer to the first ledge.");
  }
  if ($text=~/puma/i) {
    if (!quest::istaskactive(600110) && !quest::istaskcompleted(600110)) {
      quest::say("Those stupid pumas! Every time I turn my back they sneak into my stores of meat for the griffons and eat it all up! Kill a few mountain pumas for me and I'll be grateful.");
      quest::assigntask(600110);
    }
  }
  if ($text=~/afraid/i) {
    quest::say("Well of course I'm afraid! Grumpy griffons are no laughing matter. Thin out those pumas for me, would you?");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
