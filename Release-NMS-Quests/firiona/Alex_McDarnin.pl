#Alex_McDarnin, Firiona Vie
# items: 19269, 19238, 19264, 19272, 19267, 19271, 19274, 19266

sub EVENT_SAY {
  if($text=~/Hail/i) {
    quest::say("Hail! Do you by chance bring news from the North? I sure do miss the cold. It is just a bit too warm for me down here. Well, I wish you the best of luck in your travels. Tomorrow is a new day and I am off in search of [new writings] to take back to the Tribunal.");
    return;
  }
  if($text=~/new writings/i) {
    quest::say("There have been tales of new writings being found in some of the ancient ruins that abound outside of this outpost. These writings will be very valuable to my church. The sooner I can return with the writings, the sooner the Tribunal can put the teachings to work. I am always in need of aides so if [" . quest::saylink("I want to help", false, "you want to help") . "], just say so.");
    return;
  }
  if($text=~/want to help/i) {
    quest::say("We won't be traveling together, but here is what I need. There are four writings that still elude me. Return one of these and I'll spare one of the four extra writings I have. I am looking for the writings called Talisman of Jasinth, Spirit of Scale, Cripple, and Cannibalize III. Be off, and may your travels be safe!");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19269, 19238, 19264, 19272); #Item(s): Spell: Cripple, Spell: Spirit of Scale, Spell: Talisman of Jasinth, Spell: Cannibalize III
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19267, 19271, 19274, 19266); # Item(s): Spell: Talisman of Shadoo (19267), Spell: Shroud of the Spirits (19271), Spell: Torrent of Poison (19274), Spell: Insidious Decay (19266)
    # Exp for each turned in item
    my $handin_exp = 1000;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("say", "Here is the scroll that I promised. We have both gained much knowledge today. I hope to do business with you again soon. Farewell!");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }
}
#END of FILE Zone:firiona  ID:84173 -- Alex McDarnin