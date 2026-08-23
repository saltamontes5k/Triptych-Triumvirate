# #20451 -> teola
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
my $start;
my $timer;
my $move;

sub EVENT_ITEM {
  my $step = $zone->GetVariable($EPIC_VAR) || 0;
  if ( ($step == 3) && plugin::check_handin(\%itemcount, 20451 => 1)) {
    quest::emote("begins walking toward the gathering spot. 'Follow, friend.'");
    $start = $entity_list->GetMobByNpcTypeID(15044);
    $timer = $start->CastToNPC();
    $zone->SetVariable($EPIC_VAR, 4);
    $timer->SignalNPC(1); # start the timers on althele
  }
  plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
  if ($signal == 99) {
    quest::emote("breathes slowly as tendrils of power emanate from her body and race along the ground.");
  }
  else {
    quest::moveto(-1597,-3670,-18);
    $move = 1;
  }
}

sub EVENT_WAYPOINT_DEPART {
  if ($move == 1) {
    quest::spawn2(15170,0,0,-1597,-3670,-18,0); # NPC: Teloa
    quest::depop();
  }
}

# EOF zone: eastkarana ID: 15170 NPC: Teola
