#Quest Name: Necromancer Spells
#Author: JanusD
#Zone: The Overthere
#NPC Name: Vaean the Night
#NPC ID: 93113
#Quest Items Needed: Spell: Convergence (19423), Spell: Defoliation(19296), Spell: Splurt(19294), and Spell: Thrall of Bones(19299)
# items: 19423, 19296, 19294, 19299, 19297, 19421, 19408, 19409


sub EVENT_SAY {
  if($text =~ /hail/i){
    quest::say("Ahh, welcome! More souls to succumb to the inhabitants of the Outlands! My army of undead will grow stronger by the day, but it would be a pity if you perished before doing a [mortal bidding] for me.");
    return;
  }

  if($text=~/mortal bidding/i){
    quest::say("I see it as a win-win situation for me. If you succeed, I'll gain more power from the knowledge you bring back to me. If you fail, you become another addition to my undead minions. Thus, you cannot fail me in returning a scroll of Splurt, Defoliation, Covergence, or Thrall of Bones. In return, I will part with a scroll of mine.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (19423, 19296, 19294, 19299); #Item(s): Spell: Convergence, Spell: Defoliation, Spell: Splurt, Spell: Thrall of Bones
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (19297, 19421, 19408, 19409); # Item(s): Spell: Minion of Shadows (19297), Spell: Sacrifice (19421), Spell: Scent of Terris (19408), Spell: Shadowbond (19409)
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
#END of FILE Zone:overthere  ID:84166 -- Vaean the Night