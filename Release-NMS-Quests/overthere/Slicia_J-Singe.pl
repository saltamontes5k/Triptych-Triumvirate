# items: 19351, 19347, 19354, 19358, 19368, 19346, 19355, 19357
sub EVENT_SAY { 
  if($text=~/hail/i){
    quest::say("Why is it that you have come to this place? If you are coming here to search for [magical scrolls], just get back on that so-called ship you came here on and forget everything you thought you heard.");
    return;
  }
  if($text=~/magical scrolls/i){
    quest::say("Is your hearing failing you!? Unless you [" . quest::saylink("I have something you need", false, "have something I need") . "]. be gone!");
    return;
  }
  if($text=~/have something you need/i){
    quest::say("I must have the scrolls of Gift of Xev, Bristlebane's Bundle, Quiver of Marr, and the Scars of Sigil. If you don't have one of these. leave my sight!  If you do. I think we can work up a fair trade.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19351, 19354, 19358, 19347); #Item(s): Spell: Bristlebane's Bundle, Spell: Quiver of Marr, Spell: Scars of Sigil, Spell: Gift of Xev
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19368, 19346, 19355, 19357); # Item(s): Spell: Boon of Immolation (19368), Spell: Scintillation (19346), Spell: Vocarate: Fire (19355), Spell: Vocarate: Air (19357)
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
#END of FILE Zone:overthere  ID:93099 -- Slicia_J`Singe 