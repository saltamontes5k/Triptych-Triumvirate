# #20451 -> nuien -> gives 20451 & spawns Teola
#
# items: 20451

# zone‐wide progression variable
my $EPIC_VAR    = "rd_epic_step";
# NPC Type IDs 
my $NPC_ALTHELE = 15044;
my $NPC_SIONAE  = 15178;
my $NPC_NUIEN   = 15167;
my $NPC_TELOA   = 15170;
my $move;

sub EVENT_ITEM {
  my $step = $zone->GetVariable($EPIC_VAR) || 0;
  if (($step == 2) && plugin::check_handin(\%itemcount, 20451 => 1)) {
    quest::say("So be it. Do as you have done before and find the next. Teloa is the last.");
    quest::summonfixeditem(20451); # Item: Frayed Braided Grass Amulet
    quest::unique_spawn(15170,0,0,-2854,-3840,126.5,123.6); #spawn teola
    quest::signalwith(15044,15167,0); # NPC: Althele
    $zone->SetVariable($EPIC_VAR, 3);
  }
  plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
  if ($signal == 99) {
    quest::emote("growls as his power seeps into the earth.");
  }
  else {
    quest::moveto(-1590,-3671,-18);
    $move = 1;
  }
}

sub EVENT_WAYPOINT_DEPART {
  if ($move == 1) {
    quest::spawn2(15167,0,0,-1590,-3671,-18,0); # NPC: Nuien
    quest::depop();
  }
}

# EOF zone: eastkarana ID: 15167 NPC: Nuien

