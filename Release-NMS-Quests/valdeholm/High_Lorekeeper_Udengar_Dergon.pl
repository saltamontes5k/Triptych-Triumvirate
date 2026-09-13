# High Lorekeeper Udengar Dergon - Valdeholm (TSS instanced raid encounter)
# npc: 600110   loyalist: 600111   hammers: 600113 / 600114   dz template: 6004 (valdeholm version 2)

sub EVENT_SPAWN {
  quest::setnexthpevent(50);
  quest::settimer("hammers", 40);
  quest::settimer("speech", 3);
}

sub EVENT_TIMER {
  if ($timer eq "speech") {
    quest::stoptimer("speech");
    quest::shout("Welcome, fellow citizens. Thank you for your time. Your dedication to the lore of our people and your duty as citizens of Valdeholm is well fulfilled.");
    quest::shout("There were once a great people, dedicated to their god, their beliefs, their honor and their way of life. They lived beyond the sight of most of the world, untouched by its corruption.");
    quest::shout("Some of these great beings chose to do little, expecting servants to deal with the invaders. Few even knew that they were at war until it was far too late.");
    quest::shout("It is convenient for some of us to forget these things, because remembering them brings us shame in what we have allowed ourselves to become.");
  }
  if ($timer eq "hammers") {
    if ($npc->IsEngaged()) {
      my $n = quest::ChooseRandom(1, 2);
      for (my $i = 0; $i < $n; $i++) {
        my $x = $npc->GetX() + int(rand(70)) - 35;
        my $y = $npc->GetY() + int(rand(70)) - 35;
        my $z = $npc->GetZ();
        quest::spawn2(600113, 0, 0, $x, $y, $z, 0);
      }
    }
  }
}

sub EVENT_AGGRO {
  quest::shout("So the 'invaders' come at last. You are far too late - the god of war will judge you!");
}

sub EVENT_HP {
  if ($hpevent == 50) {
    quest::shout("Enough! Zek, lend me your hammers!");
    quest::spawn2(600111, 0, 0, $npc->GetX() + 30, $npc->GetY(), $npc->GetZ(), 0);
    quest::spawn2(600114, 0, 0, $npc->GetX() - 30, $npc->GetY(), $npc->GetZ(), 0);
    quest::spawn2(600114, 0, 0, $npc->GetX(), $npc->GetY() + 30, $npc->GetZ(), 0);
    quest::setnexthpevent(25);
  }
  elsif ($hpevent == 25) {
    quest::shout("I will not fall to the likes of you!");
    quest::spawn2(600114, 0, 0, $npc->GetX(), $npc->GetY() - 30, $npc->GetZ(), 0);
    quest::setnexthpevent(-1);
  }
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("The Lorekeeper's Pit falls silent. High Lorekeeper Udengar Dergon has fallen.");
}
