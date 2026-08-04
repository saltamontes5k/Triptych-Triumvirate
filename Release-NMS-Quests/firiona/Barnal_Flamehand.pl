# items: 19315, 19322, 19318, 19319, 19329, 19320, 19324, 19317
sub EVENT_SAY { 
  if($text=~/Hail/i){
    quest::say("And a fine day to you, too, $name! What is it that brings you here? Fortune? Adventure? In either case. it will be more fun than the duty I have. I am to acquire what scrolls I can for the High Council of Erudin. And you're also in luck, as I seek the services of a mighty adventurer like yourself. Do you wish to [" . quest::saylink("aid you in your duty", false, "aid me in my duty") . "]?");
    return;
  }
  if($text=~/aid you in your duty/i){
    quest::say("Then you will do this for me. Venture beyond this outpost to the most distant lands and the darkest dungeons. Within them. the creatures with the greatest power will have scrolls. The residents here will be able to give you general locations of the most dangerous places. I wish to obtain the scrolls of Atol's Spectral Shackles, Tears of Druzzil, Inferno of Al'Kabor, and lastly, Pillar of Frost. Make haste, as the High Council cannot be kept waiting! Fear not. I shall [reward] you well.");
    return;
  }
  if($text=~/reward/i){
    quest::say("I am not empty-handed. I have already located some of the most rare scrolls. I'll part with one of my four for what you return to me. Fare thee well!");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19315, 19322, 19318, 19319); #Item(s): Spell: Atol's Spectral Shackles, Spell: Inferno of Al'Kabor, Spell: Pillar of Frost, Spell: Tears of Druzzil
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19329, 19320, 19324, 19317); # Item(s): Spell: Tears of Solusek (19329), Spell: Abscond (19320), Spell: Thunderbolt (19324), Spell: Tishan`s Discord (19317)
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
#END of FILE Zone:firiona  ID:84166 -- Barnal_Flamehand