## player.pl
##
# items: 53481, 53482, 53485, 53484, 53486

#Task 5431 - Ways of Nature - Initiate Dakkan
#Task 5427 - Snake Sacs - Initiate Dakkan
#Task 10644 - Cap of Color - Jinkin
#Task 6800 - Here Kitty, Kitty - Jinkin
#Task 10645 - Thrills and Quills - Jinkin

sub EVENT_TASK_STAGE_COMPLETE {
  if ($task_id == 5431 && $activity_id == 1) { #Ways of Nature Step 2
    quest::summonitem(53481, 5); #Potion of Minor Relief x 5
    quest::signal(394147); ##Initiate Dakkan
    $client->Message(4,"Dakkan is one step further in his quest to learn about nature and could use your help.");
    quest::exp(500);
    quest::ding();
  }
  if ($task_id == 5427 && $activity_id == 1) { #Snake Sacs Step 2
    quest::summonitem(53482, 5); #Potion of Quickened Thought x 5
    quest::signal(394147); ##Initiate_Dakkan
    $client->Message(4,"Dakkan is getting closer to learning all he needs to about poison, but he still has more to learn.");
    quest::exp(500);
    quest::ding();
  }
  if ($task_id == 10644 && $activity_id == 1) {
    quest::summonitem(53485, 10); # Item: Sporeling Essence Potion
    $client->Message(4,"Jinkin now has a full supply of dye, but as diligently as she works, it won't last long.");
    quest::exp(500);
    quest::ding();
  }
  if ($task_id == 6800 && $activity_id == 2) {
    quest::summonitem(53484, 10); # Item: Jinkin's Hearty Elixir
    $client->Message(4,"Jinkin has enough fangs now to complete her necklace, but she still has a lot of work to do!");
    quest::exp(500);
    quest::ding();
  }
  if ($task_id == 10645 && $activity_id == 3) {
    quest::summonitem(53486); # Item: Quill-Studded Bracer
    $client->Message(4,"Jinkin has enough hides to make many bracelets now. Hopefully, someone will buy them . . .");
    quest::exp(500);
    quest::ding();
  }
  if ($task_id == 505746 && $activity_id == 1) {
    quest::summonitem(57974); #Crescent Reach City Charter
    $client->Message(4, "You pull the city charter from the bookshelf and your heart begins to beat just a little faster. You feel just a bit more at home in Crescent Reach.");
  }
}

sub EVENT_ENTERZONE {
  if (($ulevel >= 15) && (!defined($qglobals{Wayfarer})) && ($client->GetStartZone()==$zoneid) && quest::is_lost_dungeons_of_norrath_enabled()) {
    $client->Message(15, "A mysterious voice whispers to you, 'Vladnelg Galvern has just joined the Wayfarers Brotherhood and has some information about them, and how you can start doing odd jobs for them. You looked like the heroic sort, so I wanted to contact you . . . discreetly.'");
  }
}
# Shimmering Parchment is the original Touch of the Six click effect.
# Activity type CastOn supplies the native task UI but has no automatic
# casting dispatcher in this core. Credit the actual completed cast only.
sub EVENT_CAST {
  becoming_hero_seed_cast();
  if ($spell_id == 8691 &&
      quest::istaskactivityactive(6020, 1) &&
      $client->CountItem(84220) > 0) {
    quest::updatetaskactivity(6020, 1, 1);
  }
}

sub EVENT_CLICKDOOR { becoming_hero_throne_click(); }

# Becoming a Hero: credit a completed seed cast only; native task completion owns rewards.
sub becoming_hero_seed_cast {
 return unless $spell_id == 8699 && quest::istaskactivityactive(3039603,0);
 my $seed_slot=-1;
 for my $slot(23..32){if($client->GetItemIDAt($slot)==84231){$seed_slot=$slot;last;}}
 return if $seed_slot<0;
 my ($sx,$sy,$sz)=($client->GetX(),$client->GetY(),$client->GetZ());
 return unless $sx>=-2150 && $sx<=-1650 && $sy>=-350 && $sy<=700 && $sz>=-130 && $sz<=-40;
 my $key="becoming_hero_seed_last";
 my $done=$client->GetTaskActivityDoneCount(3039603,0);
 my $old=$client->GetBucket($key);
 if($done>0 && $old =~ /^(-?[0-9.]+),(-?[0-9.]+)$/){
  return if (($sx-$1)**2+($sy-$2)**2) < 1**2;
 }
 $client->SetBucket($key,"$sx,$sy");
 quest::updatetaskactivity(3039603,0,1);
 quest::spawn2(394933,0,0,$sx,$sy,$sz,0);
 if($client->GetTaskActivityDoneCount(3039603,0)>=10){quest::removeitem(84231,1);$client->DeleteBucket($key);}
}
sub becoming_hero_throne_click {
 return unless $doorid==18 && quest::istaskactive(3039606);
 return if abs($client->GetX()+226.163)>60 || abs($client->GetY()+1239.01)>60 || abs($client->GetZ()-123.218)>25;
 my $other=$entity_list->GetNPCByNPCTypeID(394930);
 return if $other;
 # Dated guideX-225,Y-1250; native throneZ123.218. NPC location is configurable.
 quest::spawn2(394930,0,0,-225,-1250,123.218,0);
}
