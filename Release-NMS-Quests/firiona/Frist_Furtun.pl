#Frist_Furtun, Firiona Vie
# items: 19203, 19205, 19209, 19212, 19233, 19210, 19224, 19420, 19206

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Hail to thee, adventurer! I have been sent to this new land by the Clerics of Tunare in search of the new arcane magiks said to exist beyond this outpost. I myself once searched the nearby Outlands, but to go any further would lead to my certain death. Lately, the dangers have proven to be too much for adventurers and ones like myself. Have you also ventured to this land in search of these [new magiks]?");
    return;
  }
  if($text=~/new magiks/i) {
    quest::say("Ahh, wonderful! The more souls who search for these scrolls, the sooner I'll be able to return home and share this knowledge. The magiks are in the form of scrolls held by the strongest creatures of the Outlands. You will probably have the best luck searching in the darkest depths of the dungeons beyond this outpost. You might want to talk to the residents of this outpost for locations of these dreadful places. If you should happen to have any [duplicate scrolls], please come speak to me. I might be interested in working out a trade for a scroll you do not yet have.");
    return;
  }
  if($text=~/duplicate scrolls/i) {
    quest::say("Great! The scrolls I am interested in are those of Death Pact, Upheaval, Yaulp IV, and Reckoning. If you bring me any one of these scrolls, I'll let you reach into my bag and pull out one of the four very rare scrolls that have come into my possession.");
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
#END of FILE Zone:firiona  ID:84177 -- Frist Furtun