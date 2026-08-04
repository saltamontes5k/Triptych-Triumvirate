# items: 17055, 30164

# bucket status values for bucket "CharacterID-dain-ring-9-status"
# empty = player has not shown the ring to Seneschal yet.  Will not be able to use the say phrase to get a box
# 1 = player has shown the ring, will be able to use the say phrase to get the box while Seneschal is in his bedroom


my $bucket_key = "-dain-ring-9-box-status";
my $moving = 0; # used to prevent speaking while moving
my $sayStatus = 0; # used to force a player to listen to our story before rushing to the say statement

sub EVENT_SIGNAL {
  if($signal==1) {
    quest::debug("Seneschal is leaving location: x=" . $npc->GetX() . " y=" . $npc->GetY() . " z=" . $npc->GetZ());
    quest::moveto(5,780,38,260,1); # move to the bedroom
    $moving = 1;
    quest::settimer(98,1);
  }elsif($signal==2) {
    quest::debug("Seneschal is leaving location: x=" . $npc->GetX() . " y=" . $npc->GetY() . " z=" . $npc->GetZ());
    quest::moveto(-3,693,69,252,1); # move up to the throne room
    $moving = 1;
    quest::settimer(99,1);
  }
}

sub EVENT_SAY{
  if ($moving == 0 && $sayStatus == 1){ # don't allow syntax while moving or telling our story
    if($text=~/accept this task/i){
      if(quest::get_data($client->CharacterID() . $bucket_key)=="1"){ # they have shown the ring to Seneschal
        if (!plugin::check_hasitem($client,17055) && !plugin::check_hasitem($client,1500)){ # Issue the quest item if they don't have it or the resulting item already
          quest::say("In this box, place the accursed dirk of the fallen Rodrick. With it combine the heads of every traitor you dispose of. When this is done give the box and the velium insignia ring to the Dain directly. On behalf of the crown and all good Coldain, I thank you ... May Brell be with you.");
          quest::summonitem("17055");
	  quest::settimer(97, 5); # We have issued the box.  Wait 5 seconds and say Farewell before patrolling back to the throne room
        } else {
          quest::say("Go get the heads of the traitors and return them to me in the box I provided you.");
        }
      } else {
        quest::say("I must speak to the Dain before I instruct you further.  Please speak to me while the royal court is in session.");
      } 
    }
  }
}

sub EVENT_ITEM {
  my $npcX = $npc->GetX();
  my $npcY = $npc->GetY();

  if(plugin::check_handin(\%itemcount, 30164 => 1)) {  # Showing us the 8th ring.  Get the current position of the NPC and progress if in throne room.  Else, tell them to wait until morning
    if($npcX == -3 && $npcY == 693) { # Throne Room
      quest::say("Well done %t, I have heard of your victory over the Ry'Gorr. If you are willing to assist the crown further please follow me.");
      $npc->SignalNPC(1); # move to the bedroom 
      quest::set_data($client->CharacterID() . $bucket_key, "1"); # update player data bucket
      quest::settimer(10,1); # start the timer to allow time to path to the bedroom
    }
    else {
      quest::say("I must speak to the Dain before I instruct you further. Please speak to me while the royal court is in session.");
    }
    quest::summonitem(2030164); # give the ring back to the player.  We assume it will already be the legendary version
  }
  else {
    plugin::return_items(\%itemcount);
  }
}

sub EVENT_TIMER {
  if($timer == 10 && $x == 5 && $y == 780) {
     quest::stoptimer(10);
     quest::pause(100);
     quest::say("Please, shut the door behind you. What I am about to share with you must not be overheard.");
     quest::settimer(11,10);
     $moving = 0;
  }
  elsif($timer == 11) {
    quest::stoptimer(11);
    quest::say("My army stands prepared to launch an assault on Kael itself, but one task must be completed before this can happen.");
    quest::settimer(12,10);
  }
  elsif($timer == 12) {
    quest::stoptimer(12);
    quest::say("It seems Rodrick was not alone in his treachery. There is a faction of Coldain who believe that a treaty should be signed with the Kromrif, ending our hostilities with them. This, of course, is impossible. If there is one thing our history here has taught us it is that the Kromrif simply cannot be trusted.");
    quest::settimer(13,10);
  }
  elsif($timer == 13) {
    quest::stoptimer(13);
    quest::say("These traitors are poisoning the minds of our citizens, promising great rewards to those who will betry the Dain. It will take the unbiased eye of an outlander to flush out the masterminds behind this plan. Once again we turn to you.");
    quest::settimer(14,10);
  }
  elsif($timer == 14) {
    quest::stoptimer(14);
    quest::say("Will you [accept this task] outlander?");
    $sayStatus=1;
  }
  elsif($timer == 97) { # Have given the box to the player, say farewell and move back up to the throne room
    quest::stoptimer(97);
    quest::say("Farewell");
    $sayStatus=0;
    quest::pause(1);
    $npc->SignalNPC(2);
  }
  elsif($timer == 98) { # Change moving status once we're in bedroom
    if($npc->GetX() == 5 && $npc->GetY() == 780){
      quest::stoptimer(98);
      $moving=0;
    }
  }
  elsif($timer == 99) { # Change moving status once we're in throne room
    if($npc->GetX() == -3 && $npc->GetY() == 693){
      quest::stoptimer(99);
      $moving=0;
    }
  }
}

#END of FILE Zone:thurgadinb  ID:Not_Found -- Seneschal_Aldikar 
