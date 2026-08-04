# #20448 -> Althele to start corruptor/reaver spawns for fleshbound tome
#
# items: 20448, 20450, 62810, 62811, 20452, 18959

my $entid1;
my $entid2;
my $entid3;
my $mob1;
my $mob2;
my $mob3;
my $start;
my $moving;

# zone‐wide progression variable
my $EPIC_VAR    = "rd_epic_step";
# NPC Type IDs 
my $NPC_ALTHELE = 15044;
my $NPC_SIONAE  = 15178;
my $NPC_NUIEN   = 15167;
my $NPC_TELOA   = 15170;
my $NPC_THLORIS = 15043;
my $NPC_FANG    = 15042;

sub EVENT_SPAWN {
  # on repop of Althene set epic variable to 0
  $zone->SetVariable($EPIC_VAR, 0);
}



sub EVENT_SAY {
  if ($text=~/hail/i) {
    if((plugin::check_hasitem($client, 20488) || plugin::check_hasitem($client, 62600))) {
      quest::say("Hello, friend. Beautiful is what I would call such a day normally, but lately? I sense that something is [" . quest::saylink("out of balance") . "].");
      if($client->GetGlobal("ranger_epic") ==undef) {
        quest::setglobal("ranger_epic", "1", 5, "F"); 
      }	
    }	
  }
  if ($text=~/your eyes/i) {
    quest::say("Yes. I cannot see any longer, my sight long since lost in the march of years. By the blessings of Tunare and Karana, though, I still make myself useful.");
  }
  if ($text=~/out of balance/i){
    if ($client->GetGlobal("ranger_epic") ==1) {
      quest::say("I don't know for certain what is wrong. It feels like the start of a cold, a sort of tickling at the back of Norrath's throat, if I may make such a poor metaphor. In much the same way that I can sense that you have wielded the power of nature, probably in the form of the weapons known as Swiftwind and Earthcaller, I can sense a power of illness creeping upon the land. Please, if you come across anything suspicious bring it to me. I am worried, this does not feel like a natural sickness to me. Go with the blessing of the Mother and the speed of the Storm, my child.");
    }
    elsif(plugin::check_hasitem($client, 20490) or plugin::check_hasitem($client, 62809)) { #has druid 1.0 OR Seed of Wrath
      quest::say("I am certain that you would sense it too, had you been so blessed as to be without sight. My sense of the life of Norrath is greatly heightened without the hindrance of vision. As I can sense that you have at your call the power of the lands, perhaps in the form of the Nature Walkers Scimitar. I can feel an unnatural illness creeping about the edges of Norrath. Please, if you come across anything suspicious bring it to me. I am worried about this cold sickness that I can almost taste. Go with the blessing of the Mother and the speed of the Storm, my child.");
      if($client->GetGlobal("druid_epic") ==undef) {
        quest::setglobal("druid_epic", "1", 5, "F"); 
      }
    }
    else {
      quest::say("I sense something foreboding, young one, but you should think nothing of it. The sons and daughters of nature will be able to deal with this problem.");
    }
  }
}

sub EVENT_ITEM {
  my $step = $zone->GetVariable($EPIC_VAR) || 0;
  if ( ($step == 0) && plugin::check_handin(\%itemcount, 20448 => 1)) {
    quest::emote("looks at the coin and nods gravely at you as she slips it into a fold of her clothing. 'I see. The story of this coin speaks much to me as do the words you have given me. Telin sent word that you would arrive. The tidings you bring are ill indeed. Here, take this amulet and find Sionae. She is nearby. We will speak more on this matter when all are present.'");
    quest::summonfixeditem(20450); # Item: Braided Grass Amulet
    quest::unique_spawn(15178,0,0,-1595,-2595,3.2,254); #spawn sionae
      $zone->SetVariable($EPIC_VAR, 1);
    }
  elsif( ($step == 0) && plugin::check_handin(\%itemcount, 20450 => 1)){  #allow players to restart if bugged
    quest::emote("The tidings you bring are ill indeed, we shall try to gather once more. Find Sionae and make haste this time. She is nearby. We will speak more on this matter when all are present.'");
    quest::summonfixeditem(20450); # Item: Braided Grass Amulet
    quest::unique_spawn(15178,0,0,-1595,-2595,3.2,254); #spawn sionae
      $zone->SetVariable($EPIC_VAR, 1);
    }
  elsif( ($step == 0) && plugin::check_handin(\%itemcount, 20451 => 1)){ #allow players to restart if bugged
    quest::emote("The tidings you bring are ill indeed, we shall try to gather once more. Find Sionae and make haste this time. She is nearby. We will speak more on this matter when all are present.'");
    quest::summonfixeditem(20450); # Item: Braided Grass Amulet
    quest::unique_spawn(15178,0,0,-1595,-2595,3.2,254); #spawn sionae
      $zone->SetVariable($EPIC_VAR, 1);
    }
  elsif (plugin::check_handin(\%itemcount, 20452 => 1)) {
    quest::emote("hands the book to Tholris who reads through it with lines of concern etched on his face, then whispers into her ear. 'Dire news, indeed. This cannot be allowed. I must keep this book but you, $name, must not allow Innoruuk to seed the land with his hatred and filth. You have only just begun your quest. The path you are guided upon will be difficult, if not impossible, but someone must finish it. Please, take this, read of it, follow its instructions. Tunare bless your path and Karana watch over you.");
    quest::exp(100000);
    quest::summonfixeditem(18959); # Item: Earth Stained Note
    $zone->SetVariable($EPIC_VAR, 0);
    quest::depopall($NPC_SIONAE);
    quest::depopall($NPC_NUIEN);
    quest::depopall($NPC_TELOA);
    quest::depopall($NPC_THLORIS);
    quest::depopall($NPC_FANG);
    quest::depop_withtimer();
  }
  plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
  if ($signal == 15178) {
    $start = $entity_list->GetMobByNpcTypeID(15178);
    $moving = $start->CastToNPC();
    $moving->SignalNPC(1);
  }
  elsif($signal == 11111){
	quest::say("Tholris found these on the shore a little while ago. I don't see how they could be related to your search, but take them if you need them.");
  }
  elsif ($signal == 15167) {
    $start = $entity_list->GetMobByNpcTypeID(15167);
    $moving = $start->CastToNPC();
    $moving->SignalNPC(1);
  }
  else {
  quest::settimer("prep",90);
  quest::settimer("attack",120);
  quest::settimer("depop",600);
  $start = $entity_list->GetMobByNpcTypeID(15170);
  $moving = $start->CastToNPC();
  $moving->SignalNPC(1);
  }
}

sub EVENT_TIMER {  
  if ($timer eq "prep") { # gives the last druid, teloa, time to walk to the gathering
    quest::stoptimer("prep");    
    quest::say("Great mother of life and father of sky, growth and spirit, Tunare and Karana. Innoruuk once again schemes and we have failed in our duties to protect our land. We give our powers in sacrifice for your help. Heed our call and send us your wisdom.");
    quest::signalwith(15178,99,3); # NPC: Sionae
    quest::signalwith(15167,99,6); # NPC: Nuien
    quest::signalwith(15170,99,9); # NPC: Teloa
    quest::signalwith(15043,99,12); # NPC: Tholris
  }
  elsif ($timer eq "attack") { #dark elves start to make their way to the gathering
    quest::stoptimer("attack");
    quest::emote("snaps her head towards you. 'Innoruuk's brood is upon us. Go, find the spawn of hatred before they reach this point and destroy them!");

    $entid1 = quest::spawn2(15153,0,0,-996,-1529,354,260); #corruptor
    $entid2 = quest::spawn2(15150,0,0,-1090,-1529,355.4,260); #reaver
    $entid3 = quest::spawn2(15150,0,0,-1063,-1490,367.5,260); #reaver
    $mob1 = $entity_list->GetMobID($entid1);
    $mob2 = $entity_list->GetMobID($entid2);
    $mob3 = $entity_list->GetMobID($entid3);
    my $mob1attack = $mob1->CastToNPC();
    my $mob2attack = $mob2->CastToNPC();
    my $mob3attack = $mob3->CastToNPC();
    $mob1attack->AddToHateList($npc, 1);
    $mob2attack->AddToHateList($npc, 1);
    $mob3attack->AddToHateList($npc, 1);
  }
  elsif ($timer eq "depop") { #something might have gone wrong resetting the druids after 10 minutes
    quest::stoptimer("depop");
    $zone->SetVariable($EPIC_VAR, 0);
    quest::depopall($NPC_SIONAE);
    quest::depopall($NPC_NUIEN);
    quest::depopall($NPC_TELOA);
    quest::depopall($NPC_THLORIS);
    quest::depopall(15153);
    quest::depopall(15150);
    quest::depop_withtimer();
  }
}

# EOF zone: eastkarana ID: 15044 NPC: Althele

