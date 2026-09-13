sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!$client->GetBucket('newbieRewardBits')) {
      quest::emote("ripples softly");
      quest::say("Oh my, the tides have carried you far from me, haven't they? I could never forget a soul I once walked the deep with. 
                  Hail $name! Let me see that shimmering writ and I'll give you what the current owes you.");
      if (!plugin::check_hasitem($client, 18471)) {
        $client->SummonItem(18471);
        $client->Message(263, "You find a water-stained note in your pocket.");
      }
    } else {
      quest::emote("ripples softly");
      quest::say("The current brings us back together!");
      RewardItems($client);
    }
  }
  if ($text=~/note/i) {
    $client->SummonItem(18471);
    $client->Message(263, "You find a water-stained note in your pocket.");
  }
}

sub EVENT_ITEM {
    if (plugin::check_handin(\%itemcount, 18471 => 1)) {
      if (!$client->GetBucket('newbieRewardBits')) {
        RewardItems($client);
        quest::givecash(0,6,2,0);
      }
    } else {
        quest::say("The deep has no use for this, $name. Perhaps you should keep it.");
    }  
    # Return items that are not used
    plugin::return_items(\%itemcount);
}

sub RewardItems {
    my ($client) = @_;

    my %classRewards = (
        1     => { items => [2005008, 2013514], cash => 3 }, # Warrior, 3 silver
        2     => { items => [2009999, 2013542], cash => 3 }, # Cleric, 3 silver
        4     => { items => [2055623, 2013514], cash => 3 }, # Paladin, 3 silver
        8     => { items => [2009998, 2008009, 2008500, 2008500, 2013514], cash => 3 }, # Ranger, 3 silver
        16    => { items => [2055623, 2013514], cash => 3 }, # Shadow Knight, 3 silver
        32    => { items => [2009999, 2013542], cash => 3 }, # Druid, 3 silver
        64    => { items => [2067133, 2013514], cash => 3 }, # Monk, 3 silver
        128   => { items => [2009998, 2013514, 9992, 15703], cash => 3 }, # Bard, 3 silver
        256   => { items => [2009997, 2013514, 44531], cash => 3 }, # Rogue, 3 silver
        512   => { items => [2009999, 2013542], cash => 3 }, # Shaman, 3 silver
        1024  => { items => [2006012, 2013566], cash => 3 }, # Necromancer, 3 silver
        2048  => { items => [2006012, 2013566], cash => 3 }, # Wizard, 3 silver
        4096  => { items => [2006012, 2013566], cash => 3 }, # Magician, 3 silver
        8192  => { items => [2006012, 2013566], cash => 3 }, # Enchanter, 3 silver
        16384 => { items => [2067133, 2013514], cash => 3 }, # Beastlord, 3 silver
        32768 => { items => [2005003, 2013514], cash => 3 }, # Berserker, 3 silver
    );

    my $playerClassBitmask = $client->GetClassesBitmask();
    my $rewardedClassesBitmask = $client->GetBucket('newbieRewardBits') || 0;
    my $rewardGiven = 0;

    if ($rewardedClassesBitmask == 0) {
        $client->SummonFixedItem(17423);
    }

    foreach my $classBitmask (keys %classRewards) {
        if (($playerClassBitmask & $classBitmask) && !($rewardedClassesBitmask & $classBitmask)) { 
            # Summon the fixed items for the class if the player does not already have them
            foreach my $item (@{$classRewards{$classBitmask}->{items}}) {
                if ($item == 2008500 || !plugin::check_hasitem_exact($client, $item)) { # Check if the player already has the item
                    $client->SummonFixedItem($item);
                }
            }
            
            $client->AddMoneyToPP(0, $classRewards{$classBitmask}->{cash}, 0, 0);
            
            $rewardedClassesBitmask |= $classBitmask; 
            $rewardGiven = 1;
        }
    }

    if ($rewardGiven) {
        $client->SetBucket('newbieRewardBits', $rewardedClassesBitmask);

        my $response = "Does this stir the waters of your memory at all? I think you'll find that if you look around here long enough, the deep will seem more and more like home. If you are ready to start your adventure, speak to Tearel to learn how to get around.";
        if (plugin::MultiClassingEnabled()) {
            $response = "Does this stir the waters of your memory at all? Perhaps your spirit yearns for a different current this time around. Go and speak to the guild masters that have taken refuge here. They may just be willing to let you learn their ways. After you've decided which paths are for you, return to me for equipment more suited to your new endeavors. If you are ready to start your adventure, speak to Tearel to learn how to get around."; # Add multiclass response text here
        }

        quest::say($response);
    }
}
