#Heretic Drahur.pl
#Necromancer PoP Spells
# items: 59621, 28426, 59618, 29112, 21638, 21640, 28413, 28417, 26946, 28418, 28419, 29131, 26945, 28414, 28420, 28421, 28422, 28415, 28423, 28424, 28559, 29132, 28416, 28425, 28427

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Salutations. The keepers of necromancy in New Tanaan are neither your enemy or foe, as they may have been upon the material world of Norrath. Though our natures are in tact, we have elevated ourselves beyond the petty, debased bickering that Norrath has come to embody over the passing eras. All adventurers and intelligent beings are welcome in our midst, for we share only the common goal of knowledge and personal betterment in our power. I have gathered tomes and spells that I no longer have use for, as I have ascended beyond Norrath's limitations of the dark arts. However, you remain a mortal still and your abilities may never reach the esteemed levels of ours, bur do not let this discourage you. Search my tomes and perhaps I hold something of importance or relevance to your current quest for power. There is another realm of magic that I am quite familiar with, as well -- the aspects of planar magic.");
    return;
  }
}

sub EVENT_ITEM {
  # Check for our spell turnins for Ethereal Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29112);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28426, 21638, 21640, 28413, 28417, 26946, 28418, 28419, 26945); #Level 61 or 62 Necromancer spell, PoP (Touch of Mujaki, Neurotoxin, Shield of the Arcane, Legacy of Zek, Petrifying Earth, Rune of Death, Saryrn's Kiss, Greater Immobilize - given here due to other class access)
    # Exp for each turned in item
    my $handin_exp = 0;  
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. The erudite inspects the incorporeal item for a brief amount of time. He then closes his eyes and begins a dark chant that causes the air about you to grow cold and stiff - your breathing is briefly impaired and for a single moment, you feel as if you are about to suffocate. As the erudite's voice falls back to silence, the discomfort fades and you look upon the item in his hands. It is corporeal now - tangible in all aspects. Runes of inky black have formed upon the item - runes that you recognize immediately as those of necromantic foundations. The erudite gives a gentle nod of his head and hands the scroll to you.", "say", "This should prove more than useful for your endeavors in the planes. However, it extends beyond such limits and can be applied to the primordial world.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }

  # Check for our spell turnins for Spectral Parchment
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29131);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (59621, 28414, 28420, 28421, 28422, 28415, 28423, 28424, 28559, 59618); #Level 63 or 64 Necromancer spell, PoP (Force Shield, Death's Silence, Embracing Darkness, Saryrn's Companion, Shield of Maelin, Seduction of Saryrn, Touch of Death, Destroy Undead)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. The erudite inspects the incorporeal item for a brief amount of time. He then closes his eyes and begins a dark chant that causes the air about you to grow cold and stiff - your breathing is briefly impaired and for a single moment, you feel as if you are about to suffocate. As the erudite's voice falls back to silence, the discomfort fades and you look upon the item in his hands. It is corporeal now - tangible in all aspects. Runes of inky black have formed upon the item - runes that you recognize immediately as those of necromantic foundations. The erudite gives a gentle nod of his head and hands the scroll to you.", "say", "This should prove more than useful for your endeavors in the planes. However, it extends beyond such limits and can be applied to the primordial world.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  }

  # Check for our spell turnins for Glyphed Rune Word
  {
    ## START of setup for this quest turnin
    # List of valid item IDs that we can accept for turn ins go here
    my @valid_turnin_items = (29132);
    # List of valid item IDs that we can reward the player
    my @valid_rewards = (28416, 28425, 28427); #Level 65 Necromancer spell, PoP (Blood of Thule, Child of Bertoxxulous, Word of Terris)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item from you. The erudite inspects the incorporeal item for a brief amount of time. He then closes his eyes and begins a dark chant that causes the air about you to grow cold and stiff - your breathing is briefly impaired and for a single moment, you feel as if you are about to suffocate. As the erudite's voice falls back to silence, the discomfort fades and you look upon the item in his hands. It is corporeal now - tangible in all aspects. Runes of inky black have formed upon the item - runes that you recognize immediately as those of necromantic foundations. The erudite gives a gentle nod of his head and hands the scroll to you.", "say", "This should prove more than useful for your endeavors in the planes. However, it extends beyond such limits and can be applied to the primordial world.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
#Done, quest by Kilelen 
