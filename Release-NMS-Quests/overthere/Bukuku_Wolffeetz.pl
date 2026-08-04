#Bukuku_Wolffeetz, Overthere
# items: 19269, 19238, 19264, 19272, 19267, 19271, 19274, 19266

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Har har har! Yu funy lukking. Oooo.. do u hav doze [smarty writin's]?");
    return;
  }
  if($text=~/smarty writin/i) {
    quest::say("Me not know what dem ar for shure. Dem only hav dees names. Umm.. let me see if I can member dem. Taaalisman de umm.. Jasinth. Dat's one of dem. Spirited of Scaley?? OH!! Dis my favorite. Kripple. Den the last is the painful one. Canaabaalize canaabaalize canaabaalize. Yep, dat super duper one. Bring me bak one of dem, me trade.");
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
#END of FILE Zone:overthere  ID:93100 -- Bukuku_Wolffeetz