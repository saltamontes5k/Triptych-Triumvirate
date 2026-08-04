# items: 19203, 19205, 19209, 19212, 19210, 19224, 19420, 19206

sub EVENT_SAY { 
  if($text=~/hail/i){
    quest::say("Hello, $name. It's nice to see more able bodies around this part of the outland. We came here in search of the magical powers that are supposed to exist in the ruins and dungeons of this area. We need you to bring back evidence of this power in the form of scrolls. I can't offer much coin in payment, but I do have some rare scrolls I already brought back that may interest you, if you wish to [help in the search].");
    return;
  }
  if($text=~/help in the search/i){
    quest::say("Excellent! Here is what we are still seeking. The scrolls of Death Pact, Upheaval, Yaulp IV, and Reckoning. If you return one of these to me. I'll release one of my rare scrolls to you.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19203, 19205, 19209, 19212, 19233); #Item(s): Spell: Death Pact, Spell: Upheaval, Spell: Yaulp IV, Spell: Reckoning, Spell: Upheaval
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19210, 19224, 19420, 19206); # Item(s): Spell: Unswerving Hammer (19210), Spell: Heroic Bond (19224), Spell: Sunskin (19420), Spell: Word of Vigor (19206)
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
#END of FILE Zone:overthere  ID:93103 -- Brinaa_Darkpact 