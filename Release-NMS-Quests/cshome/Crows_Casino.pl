
sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Thank you for coming to Crow's Casino! If you would like to try your luck at a game of chance, simply hand me 5,000 platinum pieces."); 
  }
}

sub EVENT_ITEM {
  my $cash = 0;
  $cash = ($platinum * 1000) + ($gold * 100) + ($silver * 10) + $copper;
  if ($cash == 5000000) { #5000 Platinum
    quest::say("Okay, here we go! Rolling the dice!");
    my $random_result = int(rand(100));
    if ($random_result < 25) #0-24 rolls win this - 25% chance
    {
        quest::summonfixeditem(quest::ChooseRandom(36995,57825,64489,57819,57818,37538)); #Food
        quest::say("Better luck next time! Here's some food for your troubles!");
        
    }
    elsif (($random_result >= 25) && ($random_result < 50)) #25 to 49 rolls win this - 25% chance
    {
        quest::summonfixeditem(quest::ChooseRandom(56942,56940,56938,56934,56935,56944,56937)); #Distillates
        quest::say("Better luck next time! Here's a potion for your troubles!");
    }
    elsif (($random_result >= 50) && ($random_result < 71)) #50 to 70 rolls win this - 20% chance
    {
        quest::summonfixeditem(quest::ChooseRandom(41961, 48083)); #Experience Potions
        quest::say("Let the experience flow!");
    }
    elsif (($random_result >= 71) && ($random_result < 82)) #71 to 81 rolls win this - 10% chance - Pet illusions, etc.
    {
        quest::summonfixeditem(quest::ChooseRandom(67923,56052,61036,62774,66783,64711,66431,66449,67953,67883,52193,66598,61979,67145,66564)); #Polymorph, pet illusions, etc.
        quest::say("Nicely done! Congratulations $name!");
    }
    elsif (($random_result >= 82) && ($random_result < 88)) #82 to 87 - 5% chance - Illusions
    {
        quest::summonfixeditem(quest::ChooseRandom(37954,67008,43993,37999,40638,50872,40714,40686,50854,40656, 31861)); #Illusions
        quest::say("Epic! Congratulations $name!");
    }
    elsif (($random_result >= 88) && ($random_result < 91)) #88,90,90 - 3% chance - Mounts
    {
        quest::summonfixeditem(quest::ChooseRandom(59508,59513,43970,57798,54983,60437,52098,64560,54934,66317)); #Mounts
        quest::say("Epic! Congratulations $name!");
    }
    elsif (($random_result >= 91) && ($random_result < 93)) #91,92 - 2% chance - Unattuner
    {
        quest::summonfixeditem(quest::ChooseRandom(52024)); #Urthron's Ultimate Unattuner - Let's add more to the epic chance category?
        quest::say("Epic! Congratulations $name!");
    }
    elsif (($random_result >= 93) && ($random_result < 96)) #93,94,95 - 3% chance - Clockwork Banker Item
    {
        quest::summonfixeditem(quest::ChooseRandom(976008)); #Clockwork Banker Item
        quest::say("Epic! Congratulations $name!");
    }
     elsif (($random_result >= 96) && ($random_result < 99)) #96,97,98 - 3% chance - Clockwork Merchant Item
    {
        quest::summonfixeditem(quest::ChooseRandom(976009)); #Clockwork Merchant Item
        quest::say("Epic! Congratulations $name!");
    }
    else {
        quest::summonfixeditem(quest::ChooseRandom(36995,57825,64489,57819,57818,37538)); #Food - 2% chance for an else. 99,100.
        quest::say("Better luck next time! Here's some food for your troubles!"); 
    }

  }
  else {
    quest::say("Only one transaction at a time please of 5,000 platinum pieces! The casino is very busy!");
    quest::givecash($copper, $silver, $gold, $platinum);
  }
    plugin::return_items(\%itemcount);
}

