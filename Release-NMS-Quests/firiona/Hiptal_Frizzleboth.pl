# items: 19351, 19347, 19354, 19358, 19368, 19346, 19355, 19357
sub EVENT_SAY { 
  if($text=~/hail/i){
    quest::say("Bah!! It's not been a good day! Reports from the Outlands are even worse than I was led to believe. Many would-be adventurers have turned up missing of late. One of them was one of my messenger. He was out collecting some of the various new and [interesting scrolls] that have been surfacing in the farthest reaches of this land. I fear for his safety and that of the others searching for the lost travelers. I wish there was more I could do.");
    return;
  }
  if ($text=~/interesting scrolls/i) {
    quest::emote("reaches into his pouch.");
    quest::say("Well, let's see what I have in here. Ah, yes. The scrolls are definitely worth finding. Possibly even dangerous if they should fall into the wrong hands. But that is why the Collective sent me here. To procure all of the scrolls so that they may be studied at the Library of Mechanimagica. Bah!! But my messenger is missing! I can't fail them. Would you be willing to [help locate] some of the scrolls I am missing?");
    return;
  }
  if($text=~/help locate/i){
    quest::say("You would do that for me? Of course you would, you realize how important my work is here. Your task is quite simple, really. I'll part with one of my rare scrolls if you bring me one of the common ones from the surrounding areas. To be more precise, I am looking for the scrolls Gift of Xev and Bristlebane's Bundle. Oh, my nephew is going to love these! I can't wait to get my hands on them! I'm also looking for the scrolls Quiver of Marr and Scars of Sigil. Bring them back to me as soon as you find one.");
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
#END of FILE Zone:firiona  ID:84168 -- Hiptal_Frizzleboth 