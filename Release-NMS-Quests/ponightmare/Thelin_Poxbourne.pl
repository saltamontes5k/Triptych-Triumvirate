# items: 9258, 9259
sub EVENT_SPAWN {
   quest::settimer(2,7200);
}

sub EVENT_DEATH_COMPLETE {
   $spawn_mob1 = undef;
   $flag = undef;
   $dagger = undef;
   $spawn_CYCLE = undef;
   quest::signalwith(204037, 5, 0); # NPC: #Thelin_Poxbourne
   quest::stoptimer(2);
}

sub EVENT_TIMER {
   if($timer == 2) {
      $spawn_mob1 = undef;
      $flag = undef;
      $dagger = undef;
      $spawn_CYCLE = undef;
      quest::depop();      
      quest::stoptimer(2);
   }

   if($timer == 9) {
      quest::depop();
      $spawn_mob1=undef;
      $flag=undef;
      $dagger=undef;
   }

   if($timer == 6) {
      $spawn_mob1=undef;
   }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 9258 => 1)) {
      $dagger=1;
      quest::emote("takes the final shard from you and places all of the pieces on the ground. The pieces reassemble and fuse back together into a completed dagger.  Thelin picks the dagger up and hands it to you.");
      quest::summonitem(9259); #Thelin's Dagger
      quest::exp(100000); #unconfirmed
      quest::spawn2(204065,0,0,-4554,5018,5,260); # NPC: #Terris_Thule
      quest::depop();
      $spawn_mob1=undef;
      $spawn_CYCLE = undef;
      $flag=undef;
      $dagger=undef;
      quest::spawn2(204067,0,0,$x,$y,$z,0); # NPC: __Thelin_Poxbourne
   }
}