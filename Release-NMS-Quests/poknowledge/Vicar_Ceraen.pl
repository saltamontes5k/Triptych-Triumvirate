#Vicar Ceraen.pl
#Cleric PoP Spells
# items: 59579, 59578, 28556, 29112, 28646, 28557, 28561, 28572, 21690, 26945, 26946, 28558, 28563, 28566, 28567, 28564, 26947, 29131, 21647, 28569, 28571, 28573, 28559, 28560, 28562, 29132, 21689, 28555, 28565, 28568, 28570

sub EVENT_SAY {
  if($text=~/hail/i) {
    quest::say("Greetings, $name. I am Ceraen, priest of Tunare and resident of New Tanaan for over three centuries of my existence. Do not fear those whom may have been your enemy upon the prime. The scholars are equal and without bias toward one another, thus there is no safer place in the cosmos than New Tanaan. Each resident strives to bring knowledge closer to the curious and willing, and I am not exempt from this. If you are a priest in your world and seek to gain a higher understanding of the divine power that your faith has allowed you to wield, then perhaps what spells I have penned from memory of your world would be of use. I have also mastered levels in the workings of planar magic and its chaotic ways of forming upon the manifested planes. If by chance you come across a fledgling arcane item -- you will know it for its incorporeal state -- then do not hesitate to bring it to me. I may be able to infuse it with the powers of the divine and forge from it a spell of priestly might.");
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
    my @valid_rewards = (59578, 28556, 28646, 28557, 28561, 28572, 21690, 26945, 26946, 28558, 28563, 28566, 28567, 28564, 26947); #Level 61 or 62 Cleric spell, PoP (Faith, Symbol of Kazad, Ward of Gallantry, Tarnation, Sermon of Penitence, Petrifying Earth, Greater Immobilize, Virtue, Blessing of Reverence, Supernal Elixir, Condemnation, Catastrophe, Pacification)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item with great care and respect from you. For several moments the priest seems to enter a state of contemplative meditiation upon the arcane planar item. Suddenly, he begins a slow, soft chant -- a prayer whose dialect is unknown to your ears. Eventually, the arcane item in his hand begins to waver into this existence, its corporeal state rendered beneath the priest's chanting. As he grows quiet and calm once more, the priest hands the corporeal item to you -- the runes of divine power etched upon the tangible scroll.", "say", "This should be of great use to you, $name. Use its power wisely.");
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
    my @valid_rewards = (59579, 21647, 28569, 28571, 28573, 28559, 28560, 28562); #Level 63 or 64 Cleric spell, PoP (Kazad's Mark, Hammer of Damnation, Supernal Light, Sound of Might, Destroy Undead, Mark of Kings, Word of Replenishment)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item with great care and respect from you. For several moments the priest seems to enter a state of contemplative meditiation upon the arcane planar item. Suddenly, he begins a slow, soft chant -- a prayer whose dialect is unknown to your ears. Eventually, the arcane item in his hand begins to waver into this existence, its corporeal state rendered beneath the priest's chanting. As he grows quiet and calm once more, the priest hands the corporeal item to you -- the runes of divine power etched upon the tangible scroll.", "say", "This should be of great use to you, $name. Use its power wisely.");
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
    my @valid_rewards = (21689, 28555, 28565, 28568, 28570); #Level 65 Cleric spell, PoP (Yaulp VI, The Silent Command, Armor of the Zealot, Mark of the Righteous, Hand of Virtue)
    # Exp for each turned in item
    my $handin_exp = 0;
    # What to do when there is a success on the handin, an array with the pattern of ("say" or "emote", "what to say or emote")
    my @handin_success = ("emote", "takes the arcane item with great care and respect from you. For several moments the priest seems to enter a state of contemplative meditiation upon the arcane planar item. Suddenly, he begins a slow, soft chant -- a prayer whose dialect is unknown to your ears. Eventually, the arcane item in his hand begins to waver into this existence, its corporeal state rendered beneath the priest's chanting. As he grows quiet and calm once more, the priest hands the corporeal item to you -- the runes of divine power etched upon the tangible scroll.", "say", "This should be of great use to you, $name. Use its power wisely.");
    ## END of setup for this quest turnin

    # # Create a hash for quick lookup of valid items
    my %valid_lookup = map { $_ => 1 } @valid_turnin_items;
    # # store our item handin variables, this has to be two arrays otherwise the same item in more than one slot is an issue with a hash and keys being unique
    my @turnin_items = ($item1, $item2, $item3, $item4);
    my @turnin_stack_size = ($item1_charges, $item2_charges, $item3_charges, $item4_charges);

    plugin::do_stack_handin_quest(\@turnin_items, \@turnin_stack_size, \@valid_turnin_items, \@valid_rewards, $handin_exp, \@handin_success);
  } 
}
#END of FILE Zone:poknowledge  ID:202218 -- Vicar_Ceraen 