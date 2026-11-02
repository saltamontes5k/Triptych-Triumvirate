#--------------------------------------------------------------------------
# TBS Katta Castrum - Archarcanist Pintanus (416024)
# Orux mission: Leave No Stone Unturned (620109) - dz template 6119.
# Urn tasks: Adapting to the Environment (620122), Adapting II (620123),
# Snakes on the Plain (620126), Remnants of a Lost Civilization (620128),
# Remnants II (620129), Eye in the Sky (620131) -> the Worn and Smudged
# Pottery sets.
#--------------------------------------------------------------------------
my $MISSION = 620109;
my $MZONE   = 419;   # zhisza

my @order = (620122, 620123, 620126, 620128, 620129, 620131);
my %tasks = (
  620122 => ['interested', 'Zhisza\'s vermin adapt faster than we can catalog them. [interested]? Cull the deathspore insects and bring me wings and mandibles.'],
  620123 => ['another', '[Another] study, then: the serpents and the great apes. Sacs and fangs, if you please.'],
  620126 => ['plain', 'Three [plain]-walkers have grown too clever: Copperfang, King Brownscale, Coralitus. End their reign.'],
  620128 => ['more', 'The rubble of Silyssar hides [more] than stone. Break the piles open and bring me the Shissar Artifacts inside.'],
  620129 => ['fragments', 'The [fragments] interest me most: the brackwater elementals and goos carry Artifact Shards. Ten of each dead, five shards brought back.'],
  620131 => ['pyramids', 'The [pyramids] watch everything. Clear the trash from around all three portals and I will see the ground from their eyes.'],
);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive($MISSION)) {
      quest::say("The stone remembers who unturned it. Say [enter] when your companions are gathered.");
      return;
    }
    if (quest::istaskcompleted($MISSION) && !quest::get_data($client->CharacterID() . "-tbsm-$MISSION")) {
      quest::say("Not one stone left unturned. Your Orux, scholar -- the archive grows.");
      quest::set_data($client->CharacterID() . "-tbsm-$MISSION", 1);
      return;
    }
    my $next = -1;
    for my $t (@order) {
      if (!quest::istaskcompleted($t)) { $next = $t; last; }
    }
    if ($next >= 0) {
      quest::say($tasks{$next}[1]);
      return;
    }
    quest::say("The studies are complete, $name. Zhisza and Silyssar hold no more surprises for me -- through you.");
    return;
  }
  if ($text=~/undertake|mission|stone/i) {
    if (!quest::istaskactive($MISSION) && !quest::istaskcompleted($MISSION)) {
      quest::assigntask($MISSION);
      quest::say("Zhisza's temples keep their secrets buried. Say [enter] when prepared.");
    } elsif (quest::istaskactive($MISSION)) {
      quest::say("Say [enter] - the temples wait.");
    } else {
      quest::say("It is decided, and well.");
    }
    return;
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($MISSION)) {
      quest::say("Zhisza remembers its emperor. Make it forget.");
      $client->MovePCDynamicZone($MZONE, 0);
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("The studies will not do themselves, $name.");
    } else {
      quest::assigntask($tid);
      quest::say("Go. Catalog as you kill.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
