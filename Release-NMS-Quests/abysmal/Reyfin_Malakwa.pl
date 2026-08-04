use List::Util 'shuffle';

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::emote("stares silently out over the ocean towards the magical wards protecting the ship from the unyielding onslaught of the pounding waves. He jumps back terrorized when he realizes your presence. His visage calms a bit when he senses you mean him no immediate harm. He ponders you timidly for a moment and then leans down and begins drawing something in the sea grime that covers one of the boxes. You study his sketch for a moment and begin to understand that it is a rune of sorts. Three arching lines join in the center to form a sort of Y-shape.");
    if (plugin::check_hasitem($client, 62863)) {
      $client->Message(1, "The bedraggled Taelosian refugee looks up at you after drawing the symbol and looks you directly in the eyes for the first time. He seems to draw strength from your presence and you sense that he feels the power of nature that you carry. He smiles weakly at you and then bends down and erases the symbol by smearing around the surrounding grime. He then draws a new symbol. This symbol is much more complicated, it is an arch with rods protruding from either side at the base. The rod to the right splits into four branches, the one on the left ends in a swirl. He looks up at you with a pleading look in his eyes as he hands you a small bag that appears to be made from his own clothing");
      if ($client->GetGlobal("druid_epic") < 9) {
        quest::setglobal('druid_epic', 9, 5, 'F');
      }
      quest::summonitem(62881); #Ragged Cloth Bag
    }
  }
}

sub EVENT_ITEM {
  my %rewards = (
    59907 => {
      'Warrior' => 59909,
      'Berserker' => 59919,
      'Ranger' => 59855,
      'Bard' => 59846,
      'Rogue' => 59911,
      'Paladin' => 59852,
      'Shadowknight' => 59857,
      'Monk' => 59913,
      'Beastlord' => 59847,
      'Cleric' => 59848,
      'Druid' => 59849,
      'Shaman' => 59854,
      'Enchanter' => 59850,
      'Magician' => 59851,
      'Necromancer' => 59853,
      'Wizard' => 59856
    },
    59906 => {
      'Warrior' => 59908,
      'Berserker' => 59918,
      'Ranger' => 59835,
      'Bard' => 59811,
      'Rogue' => 59910,
      'Paladin' => 59831,
      'Shadowknight' => 59841,
      'Monk' => 59912,
      'Beastlord' => 59814,
      'Cleric' => 59821,
      'Druid' => 59823,
      'Shaman' => 59837,
      'Enchanter' => 59817,
      'Magician' => 59825,
      'Necromancer' => 59828,
      'Wizard' => 59844
    },
    59975 => {
      'Ranger' => 59836,
      'Bard' => 59812,
      'Paladin' => 59833,
      'Shadowknight' => 59842,
      'Beastlord' => 59815,
      'Cleric' => 59820,
      'Druid' => 59824,
      'Shaman' => 59839,
      'Enchanter' => 59818,
      'Magician' => 59827,
      'Necromancer' => 59830,
      'Wizard' => 59845
    },
    59974 => {
      'Ranger' => 59834,
      'Bard' => 59810,
      'Paladin' => 59832,
      'Shadowknight' => 59840,
      'Beastlord' => 59813,
      'Cleric' => 59819,
      'Druid' => 59822,
      'Shaman' => 59838,
      'Magician' => 59826,
      'Enchanter' => 59816,
      'Necromancer' => 59829,
      'Wizard' => 59843
    }
  );

  my $found = 0;

  if (plugin::check_handin(\%itemcount, 62882 => 1)) { # Wrapped Cloth Bag
    quest::setglobal('druid_epic', 10, 5, 'F');
    quest::emote("looks almost delighted, certainly happier than he has been in years. He smiles and raises his arms, both hands tightly clenching the rune fragments you have recovered. A small burst of magical energies pops off his hands. He lowers his arms and holds out to you the rune, reformed. He then speaks a single word to you, 'Yuisaha.'");
    quest::summonitem(62868); #Rune of Yuisaha
    $found = 1;
  } elsif (plugin::check_handin(\%itemcount, 62885 => 1)) { # Synched Leather Bag
    quest::setglobal('druid_epic', 12, 5, 'F');
    quest::emote("makes a motion with his hands, slowly clasping them together until they are locked tightly. He points at you, then at the shards, then makes the motion again");
    quest::summonitem(62885); #Synched Leather Bag
    $found = 1;
  } else {
    foreach my $item (keys %rewards) {
      if (plugin::check_handin(\%itemcount, $item => 1)) {
        $found = 1;
        if ($item == 59907) {
          quest::emote("eyes grow wide as you hand him the glowing black rune. He holds the chaos rune in his left hand and begins to speak. Your skin begins to crawl as you recognize the words as the language of the legion. The runes melt into a sticky mass of darkness which seeps out over Reyfin's hands. He tips his head toward your hands and you bring them out in front of you. Without any visible motion from Reyfin, the black mass quivers and slides through the air toward you and settles in your out stretched hands. The goo begins to solidify and your eyes quiver with amazement as the letters begin to form into familiar words on the black stone.");
        } elsif ($item == 59906) {
          quest::emote("shuffles back from you until familiarity dawns on him. You reach forward and hold the stone out in front of you. He tilts his head slightly and studies the stone for a moment before taking it from your hands.");
          quest::emote("holds the symbol up over his head and speaks out over the dark waters. He begins to recite some sort of ritual as the runes begin to drip a sticky-looking fluid down on to his hands and arms. The rune begins to glow, softly at first, but it becomes brighter as Reyfin's voice rises. Suddenly, the symbol sublimates into a hovering mass of glowing vapor. Reyfin turns to you and beckons. You hold out your hand and receive the glowing vapor. Almost immediately the vapor solidifies into a familiar shape. Reyfin bends down and begins drawing in the grime once again. You see a pair of jagged lines crossing in the center.");
        }

        my @possible_rewards;

        foreach my $class (keys %{$rewards{$item}}) {
          if ($client->HasClass($class)) {
            my $reward_id = $rewards{$item}{$class};
            my $key = "god-spells-$item-$reward_id";
            unless ($client->GetBucket($key)) {
              push @possible_rewards, $reward_id;
            }
          }
        }

        if (@possible_rewards) {
          my $random_reward = (shuffle(@possible_rewards))[0];
          quest::summonitem($random_reward);

          # Mark this reward as received
          my $key = "god-spells-$random_reward";
          $client->SetBucket($key, 1);
        } else {
          quest::say("You have already received all possible rewards for this item.");
        }

        quest::exp(10000);
        last;
      }
    }
  }

  plugin::return_items(\%itemcount) unless $found;
}
#END of FILE zone:abysmal ID:279029 -- Reyfin_Malakwa.pl
