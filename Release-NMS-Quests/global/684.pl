###########################################
## Main Event Handlers
###########################################

# Time interval to check if current spell should be interrupted (in seconds)
my $SPELL_INTERRUPT_CHECK_INTERVAL = 1;

sub EVENT_SPAWN {
    $npc->SetTimer("cast_check", 1);
    $npc->SetTimer("spell_interrupt_check", $SPELL_INTERRUPT_CHECK_INTERVAL);
}

sub EVENT_TIMER {
    if ($timer eq "cast_check") {
        handle_cast_check();
    } elsif ($timer eq "spell_interrupt_check") {
        check_and_interrupt_spell();
    } elsif ($timer =~ /^recast_blocker_expire_(\d+)$/) {
        my $spell_id = $1;
        quest::debug("Cooldown expired for spell $spell_id");
        $npc->DeleteEntityVariable("recast_blocker_$spell_id");
        $npc->StopTimer($timer);
    } elsif ($timer eq "global_cooldown_expire") {
        quest::debug("Global cooldown expired");
        $npc->DeleteEntityVariable("global_cooldown");
        $npc->StopTimer($timer);
    }
}

sub EVENT_CAST_BEGIN {
    quest::debug("Beginning to cast spell_id " . $spell_id);
    
    # Store the spell we're casting and its target for interrupt checks
    $npc->SetEntityVariable("current_casting_spell", $spell_id);
    $npc->SetEntityVariable("current_casting_target", $target_id);
    
    # Track beneficial spell types (only healing and runes now)
    my $is_hot = quest::IsHealOverTimeSpell($spell_id) || quest::IsGroupHealOverTimeSpell($spell_id) ? "true" : "false";
    my $is_direct_heal = (quest::IsRegularSingleTargetHealSpell($spell_id) || 
                         quest::IsFastHealSpell($spell_id) || 
                         quest::IsVeryFastHealSpell($spell_id) || 
                         quest::IsCompleteHealSpell($spell_id) || 
                         quest::IsPercentalHealSpell($spell_id)) && 
                        !quest::IsHealOverTimeSpell($spell_id) ? "true" : "false";
    my $is_rune = (quest::IsRuneSpell($spell_id) || quest::IsMagicRuneSpell($spell_id)) ? "true" : "false";
    
    # Set spell type variables
    $npc->SetEntityVariable("current_spell_is_hot", $is_hot);
    $npc->SetEntityVariable("current_spell_is_direct_heal", $is_direct_heal);
    $npc->SetEntityVariable("current_spell_is_rune", $is_rune);
}

sub EVENT_CAST {
    quest::debug("spell_id " . $spell_id);
    quest::debug("caster_id " . $caster_id);
    quest::debug("caster_level " . $caster_level);
    quest::debug("target_id " . $target_id);
    quest::debug("target " . $target);
    quest::debug("spell " . $spell);

    # Clear all spell tracking variables
    $npc->DeleteEntityVariable("current_casting_spell");
    $npc->DeleteEntityVariable("current_casting_target");
    $npc->DeleteEntityVariable("current_spell_is_hot");
    $npc->DeleteEntityVariable("current_spell_is_direct_heal");
    $npc->DeleteEntityVariable("current_spell_is_rune");
    
    handle_post_cast($spell_id);
}

# Function to check if the current spell should be interrupted
sub check_and_interrupt_spell {
    # If we're not casting, no need to check
    if (!$npc->IsCasting()) {
        return;
    }
    
    # Get information about the current spell
    my $current_spell_id = $npc->GetEntityVariable("current_casting_spell");
    my $current_target_id = $npc->GetEntityVariable("current_casting_target");
    my $is_hot = $npc->GetEntityVariable("current_spell_is_hot") eq "true";
    my $is_direct_heal = $npc->GetEntityVariable("current_spell_is_direct_heal") eq "true";
    
    # If it's not a healing spell, no need to interrupt
    if (!$is_hot && !$is_direct_heal) {
        return;
    }
    
    # Get the target entity
    my $target = $entity_list->GetMobByID($current_target_id);
    if (!$target) {
        quest::debug("Target no longer exists, interrupting spell");
        $npc->InterruptSpell($current_spell_id);
        return;
    }
    
    # Calculate target's HP percentage
    my $max_hp = $target->GetMaxHP();
    my $hp_percent = 0;
    if ($max_hp > 0) {
      $hp_percent = ($target->GetHP() / $max_hp) * 100;
    }
    
    # Interrupt logic based on spell type
    if ($is_direct_heal && $hp_percent >= 75) {
        # Interrupt direct heal if target HP is above 75%
        quest::debug("Target HP is now $hp_percent%, interrupting direct heal spell");
        $npc->InterruptSpell($current_spell_id);
    } elsif ($is_hot && $hp_percent < 40) {
        # Interrupt HoT if target HP falls below 40% (critical)
        quest::debug("Target HP dropped to $hp_percent%, interrupting HoT spell for direct healing");
        $npc->InterruptSpell($current_spell_id);
    }
}

# Function to check if another swarm member is casting a specific beneficial spell type
sub is_swarm_member_casting_beneficial_type {
    my ($target_id, $spell_type) = @_;
    
    # Get our own details
    my $my_id = $npc->GetID();
    my $owner_id = $npc->GetSwarmOwner();
    my $npc_type_id = $npc->GetNPCTypeID();
    
    # Find all NPCs of our type that belong to the same owner
    foreach my $potential_member ($entity_list->GetNPCList()) {
        # Skip if it's ourselves
        if ($potential_member->GetID() == $my_id) {
            next;
        }
        
        # Check if it's a member of our swarm
        if ($potential_member && 
            $potential_member->GetNPCTypeID() == $npc_type_id &&
            $potential_member->GetSwarmOwner() == $owner_id) {
            
            # Check if this swarm member is casting a spell of the same type at the same target
            if ($potential_member->IsCasting()) {
                my $casting_target = $potential_member->GetEntityVariable("current_casting_target");
                
                # Match on target ID
                if ($casting_target == $target_id) {
                    # Check for spell type
                    if ($spell_type eq "hot" && $potential_member->GetEntityVariable("current_spell_is_hot") eq "true") {
                        quest::debug("Another swarm member is already casting HoT on target $target_id");
                        return 1;
                    }
                    elsif ($spell_type eq "direct_heal" && $potential_member->GetEntityVariable("current_spell_is_direct_heal") eq "true") {
                        quest::debug("Another swarm member is already casting direct heal on target $target_id");
                        return 1;
                    }
                    elsif ($spell_type eq "rune" && $potential_member->GetEntityVariable("current_spell_is_rune") eq "true") {
                        quest::debug("Another swarm member is already casting rune on target $target_id");
                        return 1;
                    }
                }
            }
        }
    }
    
    return 0; # No other swarm member is casting this type of spell on this target
}

###########################################
## Main Casting Logic
###########################################

sub handle_cast_check {
    quest::debug("Checking if we can cast");
    
    # Skip if already casting
    if ($npc->IsCasting()) {
        quest::debug("Already casting, skipping");
        return;
    }
    
    # Check for global cooldown
    if ($npc->GetEntityVariable("global_cooldown") eq "true") {
        quest::debug("Global cooldown active, skipping cast check");
        return;
    }
    
    # Get owner and target
    my $owner = $entity_list->GetClientByID($npc->GetSwarmOwner());
    my $target = $npc->GetTarget();
    
    if (!$owner) {
        quest::debug("No owner found, skipping cast");
        return;
    }
    
    # Get memorized spells
    my @memmed_spells = $owner->GetMemmedSpells();
    quest::debug("Total memorized spells: " . scalar(@memmed_spells));
    
    # Split and sort spells by type
    my @beneficial_spells = get_sorted_beneficial_spells(@memmed_spells);
    my @harmful_spells = get_sorted_harmful_spells(@memmed_spells);
    
    quest::debug("Beneficial spells: " . scalar(@beneficial_spells) . ", Harmful spells: " . scalar(@harmful_spells));
    
    # First try to cast a beneficial spell on owner, group members, or pets
    if (try_cast_beneficial_spell($owner, @beneficial_spells)) {
        return; # Spell was cast, done for this round
    }
    
    # If no beneficial spell was cast and we have a target, try harmful spells
    if ($target && try_cast_harmful_spell($target, @harmful_spells)) {
        return; # Spell was cast, done for this round
    }
    
    # If we still haven't cast anything, look for other mobs aggro on our owner to cast DOTs on
    # (only if we have DOT spells available)
    my @dot_spells = grep { quest::IsStackableDOT($_) } @harmful_spells;
    if (scalar(@dot_spells) > 0) {
        quest::debug("Found " . scalar(@dot_spells) . " DOT spells, looking for additional targets aggro on owner");
        if (try_cast_dots_on_aggro_mobs($owner, @dot_spells)) {
            return; # DOT was cast, done for this round
        }
    }
    
    # If we get here, no spell was cast
    quest::debug("No suitable spell found to cast");
}

sub handle_post_cast {
    my $spell_id = shift;
    my $spell_obj = quest::getspell($spell_id);
    
    # Handle the specific spell's recast time
    my $recast_time = $spell_obj->GetRecastTime();
    if ($recast_time > 0) {
        quest::debug("Setting spell cooldown for $spell_id: $recast_time ms");
        $npc->SetEntityVariable("recast_blocker_$spell_id", "true");
        my $recast_seconds = $recast_time / 1000;
        $npc->SetTimer("recast_blocker_expire_$spell_id", $recast_seconds);
    }
    
    # Handle the global cooldown (recovery time)
    my $recovery_time = $spell_obj->GetRecoveryTime();
    if ($recovery_time > 0) {
        quest::debug("Setting global cooldown: $recovery_time ms");
        $npc->SetEntityVariable("global_cooldown", "true");
        my $recovery_seconds = $recovery_time / 1000;
        $npc->SetTimer("global_cooldown_expire", $recovery_seconds);
    }
}

###########################################
## Spell Classification and Sorting
###########################################

sub get_sorted_beneficial_spells {
    my @all_spells = @_;
    my @beneficial = grep { quest::IsBeneficialSpell($_) } @all_spells;
    
    return sort {
        my $priority_a = get_beneficial_priority($a);
        my $priority_b = get_beneficial_priority($b);
        return $priority_a <=> $priority_b;
    } @beneficial;
}

sub get_sorted_harmful_spells {
    my @all_spells = @_;
    my @harmful = grep { !quest::IsBeneficialSpell($_) } @all_spells;
    
    return sort {
        my $priority_a = get_harmful_priority($a);
        my $priority_b = get_harmful_priority($b);
        return $priority_a <=> $priority_b;
    } @harmful;
}

# Helper function to get the effective spell level for prioritization
sub get_spell_level {
    my ($spell_id) = @_;
    my $spell = quest::getspell($spell_id);
    
    my $lowest_level = 255; # Start with max value
    
    # Check all 16 class slots
    for my $class_index (0..15) {
        my $level = $spell->GetClasses($class_index);
        
        # Skip levels 254 and 255 (class can't use the spell)
        if ($level < 254) {
            # Update lowest level if this one is lower
            if ($level < $lowest_level) {
                $lowest_level = $level;
            }
        }
    }
    
    # If lowest level is still 255, no class can use this spell
    if ($lowest_level == 255) {
        return 0; # Return 0 to indicate spell is not usable
    }
    
    return $lowest_level; # Return the lowest level any class can use this spell
}

sub get_beneficial_priority {
    my $spell_id = shift;
    my $spell = quest::getspell($spell_id);
    my $buff_duration = $spell->GetBuffDuration();
    
    # Get the lowest spell level
    my $spell_level = get_spell_level($spell_id);
    
    # If the spell is not usable by any class, give it lowest priority
    if ($spell_level == 0) {
        return 999;
    }
    
    # Base priority based on spell type
    my $base_priority;
    
    # Prioritize healing spells first
    if (quest::IsHealOverTimeSpell($spell_id) || quest::IsGroupHealOverTimeSpell($spell_id)) {
        $base_priority = 1; # Highest priority - HoTs
    }
    elsif (quest::IsRegularSingleTargetHealSpell($spell_id) || 
           quest::IsFastHealSpell($spell_id) || 
           quest::IsVeryFastHealSpell($spell_id) || 
           quest::IsCompleteHealSpell($spell_id) || 
           quest::IsPercentalHealSpell($spell_id)) {
        $base_priority = 2; # Second priority - Direct heals
    }
    # Then runes
    elsif (quest::IsRuneSpell($spell_id) || quest::IsMagicRuneSpell($spell_id)) {
        $base_priority = 3; # Third priority - Protective runes
    }
    else {
        # Any remaining beneficial spells not caught by the above
        $base_priority = 99; # Very low priority for other beneficial spells
    }
    
    # For level adjustment, we want higher level spells to have better priority (lower number)
    # Since our priority system uses lower numbers for higher priority, we need to subtract
    # a value based on spell level to make higher level spells have better priority
    my $level_adjustment = $spell_level / 1000; 
    
    # Final priority = base priority minus level adjustment
    # This ensures higher level spells get slightly better priority within their category
    return $base_priority - $level_adjustment;
}

sub get_harmful_priority {
    my $spell_id = shift;
    
    # Get the lowest spell level
    my $spell_level = get_spell_level($spell_id);
    
    # If the spell is not usable by any class, give it lowest priority
    if ($spell_level == 0) {
        return 999;
    }
    
    # Base priority based on spell type
    my $base_priority;
    
    # Priority order (lower number = higher priority)
    if (quest::IsDebuffSpell($spell_id)) {
        # Prioritize debuffs first
        if (quest::IsResistDebuffSpell($spell_id)) {
            $base_priority = 1; # Highest priority - Resistance Debuffs
        } else {
            $base_priority = 2; # Second priority - Other Debuffs
        }
    } elsif (quest::IsStackableDOT($spell_id)) {
        $base_priority = 3; # Third priority - DOTs
    } elsif (quest::IsDamageSpell($spell_id)) {
        $base_priority = 4; # Fourth priority - Direct Damage
    } else {
        $base_priority = 99; # Lowest priority - Everything else
    }
    
    # For level adjustment, we want higher level spells to have better priority (lower number)
    # Since our priority system uses lower numbers for higher priority, we need to subtract
    # a value based on spell level to make higher level spells have better priority
    my $level_adjustment = $spell_level / 1000;
    
    # Final priority = base priority minus level adjustment
    # This ensures higher level spells get slightly better priority within their category
    return $base_priority - $level_adjustment;
}

###########################################
## Group and Pet Management
###########################################

# Function to get all pets owned by a character
sub get_all_pets {
    my $owner = shift;
    my @pets = ();
    
    foreach my $npc_e ($entity_list->GetNPCList()) {
        # Check if this NPC is owned by the specified owner
        if ($npc_e->GetOwnerID() == $owner->GetID()) {
            # Skip ourselves to avoid healing ourselves
            if ($npc_e->GetID() != $npc->GetID()) {
                push(@pets, $npc_e);
            }
        }
    }
    
    quest::debug("Found " . scalar(@pets) . " pets owned by " . $owner->GetName());
    return @pets;
}

# Function to get all group members and their pets
sub get_group_members_and_pets {
    my $owner = shift;
    my @targets = ();
    
    # Start with the owner
    push(@targets, $owner);
    
    # Add owner's pets
    my @owner_pets = get_all_pets($owner);
    push(@targets, @owner_pets);
    
    # Get the owner's group
    my $group = $entity_list->GetGroupByClient($owner);
    
    # If owner is in a group, add group members and their pets
    if ($group) {
        quest::debug("Owner is in a group with " . $group->GroupCount() . " members");
        
        # Loop through each group member
        for (my $count = 0; $count < $group->GroupCount(); $count++) {
            my $member = $group->GetMember($count);
            
            # Skip if member is the owner (already added)
            if ($member && $member->GetID() != $owner->GetID()) {
                quest::debug("Adding group member: " . $member->GetName());
                push(@targets, $member);
                
                # Add member's pets
                my @member_pets = get_all_pets($member);
                push(@targets, @member_pets);
            }
        }
    }
    
    quest::debug("Total targets (owner, group members, and all pets): " . scalar(@targets));
    return @targets;
}

# Function to prioritize healing targets based on their health
sub sort_targets_by_healing_priority {
    my @targets = @_;
    
    # Sort targets by health percentage (lower health = higher priority)
    my @sorted_targets = sort {
        my $hp_percent_a = ($a->GetHP() / $a->GetMaxHP()) * 100;
        my $hp_percent_b = ($b->GetHP() / $b->GetMaxHP()) * 100;
        
        # Primary sort by critical status (below 50% = critical)
        my $a_critical = ($hp_percent_a < 50) ? 1 : 0;
        my $b_critical = ($hp_percent_b < 50) ? 1 : 0;
        
        # Critical targets come first
        if ($b_critical != $a_critical) {
            return $b_critical <=> $a_critical;
        }
        
        # Then sort by lowest health percentage
        return $hp_percent_a <=> $hp_percent_b;
    } @targets;
    
    return @sorted_targets;
}

###########################################
## Spell Casting Helpers
###########################################

# Modified function to try casting beneficial spells on owner, group members, and pets
sub try_cast_beneficial_spell {
    my ($owner, @spell_list) = @_;
    
    # Get all potential healing/buffing targets (owner, group members, and all pets)
    my @all_targets = get_group_members_and_pets($owner);
    
    # First pass: Check for critical healing needs (below 50% HP)
    my @healing_targets = grep { 
        my $hp_percent = ($_->GetHP() / $_->GetMaxHP()) * 100;
        $hp_percent < 75; # Only consider targets below 75% HP for healing
    } @all_targets;
    
    # Sort healing targets by priority (most critical first)
    my @prioritized_healing_targets = sort_targets_by_healing_priority(@healing_targets);
    
    # Try to heal targets in priority order
    if (@prioritized_healing_targets) {
        quest::debug("Found " . scalar(@prioritized_healing_targets) . " targets needing healing");
        
        foreach my $target (@prioritized_healing_targets) {
            # Skip if target is self (this NPC)
            if ($target->GetID() == $npc->GetID()) {
                next;
            }
            
            my $hp_percent = ($target->GetHP() / $target->GetMaxHP()) * 100;
            quest::debug("Considering healing " . $target->GetName() . " (HP: $hp_percent%)");
            
            if (try_heal_target($target, @spell_list)) {
                return 1; # Successfully healed a target
            }
        }
    }
    
    # If no healing was needed or possible, try buffing targets (only runes now)
    # Buffing order: owner, group members, pets
    
    # Try buffing owner first
    quest::debug("Trying buff spells on owner");
    if (try_buff_target($owner, @spell_list)) {
        return 1; # Successfully buffed the owner
    }
    
    # Then try buffing group members (excluding owner)
    if ($entity_list->GetGroupByClient($owner)) {
        my $group = $entity_list->GetGroupByClient($owner);
        for (my $count = 0; $count < $group->GroupCount(); $count++) {
            my $member = $group->GetMember($count);
            
            # Skip if member is the owner (already tried)
            if ($member && $member->GetID() != $owner->GetID()) {
                quest::debug("Trying buff spells on group member: " . $member->GetName());
                if (try_buff_target($member, @spell_list)) {
                    return 1; # Successfully buffed a group member
                }
            }
        }
    }
    
    # Finally try buffing all pets
    my @all_pets = grep { 
        $_->GetOwnerID() > 0 && $_->GetID() != $npc->GetID(); # Only include entities that have an owner and aren't self
    } @all_targets;
    
    foreach my $pet (@all_pets) {
        quest::debug("Trying buff spells on pet: " . $pet->GetName());
        if (try_buff_target($pet, @spell_list)) {
            return 1; # Successfully buffed a pet
        }
    }
    
    return 0; # No spell was cast
}

# Function to specifically handle healing a target
sub try_heal_target {
    my ($target, @spell_list) = @_;
    
    # Skip if target is self (this NPC)
    if ($target->GetID() == $npc->GetID()) {
        quest::debug("Skipping self (NPC) as heal target");
        return 0;
    }
    
    # Calculate target's HP percentage
    my $hp_percent = ($target->GetHP() / $target->GetMaxHP()) * 100;
    
    # Sort beneficial spells into healing categories
    my @heal_over_time_spells = grep { quest::IsHealOverTimeSpell($_) || quest::IsGroupHealOverTimeSpell($_) } @spell_list;
    my @direct_heal_spells = grep { 
        (quest::IsRegularSingleTargetHealSpell($_) || 
         quest::IsFastHealSpell($_) || 
         quest::IsVeryFastHealSpell($_) || 
         quest::IsCompleteHealSpell($_) || 
         quest::IsPercentalHealSpell($_)) && 
        !quest::IsHealOverTimeSpell($_)
    } @spell_list;
    
    # Debug logging
    quest::debug("Found " . scalar(@heal_over_time_spells) . " HoT spells and " . 
                 scalar(@direct_heal_spells) . " direct heal spells");
    
    # If below 50% HP, prioritize direct heals
    if ($hp_percent < 50) {
        quest::debug("Target is below 50% HP, trying direct healing spells");
        
        # Try to cast a direct heal if no other swarm member is casting one
        if (!is_swarm_member_casting_beneficial_type($target->GetID(), "direct_heal")) {
            foreach my $spell_id (@direct_heal_spells) {
                quest::debug("Trying direct heal spell $spell_id");
                if (try_cast_single_spell($target, $spell_id)) {
                    return 1; # Spell was cast successfully
                }
            }
        } else {
            quest::debug("Another swarm member is already casting direct heal on this target, skipping");
        }
    }
    
    # Try heal over time spells
    if ($hp_percent < 75) {
        # Only try HoTs if no other swarm member is casting one
        if (!is_swarm_member_casting_beneficial_type($target->GetID(), "hot")) {
            foreach my $spell_id (@heal_over_time_spells) {
                # For HoT spells, check if it's already on the target
                my $has_buff_result = has_buff($target, $spell_id);
                quest::debug("HoT spell $spell_id - Target already has this buff? " . 
                            ($has_buff_result ? "Yes" : "No"));
                
                if ($has_buff_result) {
                    quest::debug("Target already has HoT spell $spell_id, skipping");
                    next;
                }
                
                quest::debug("Trying HoT spell $spell_id");
                if (try_cast_single_spell($target, $spell_id)) {
                    return 1; # Spell was cast successfully
                }
            }
        } else {
            quest::debug("Another swarm member is already casting HoT on this target, skipping");
        }
    }
    
    return 0; # No healing spell was cast
}

# Function to specifically handle buffing a target (only runes now)
sub try_buff_target {
    my ($target, @spell_list) = @_;
    
    # Skip if target is self (this NPC)
    if ($target->GetID() == $npc->GetID()) {
        quest::debug("Skipping self (NPC) as a buff target");
        return 0;
    }
    
    # Extract only rune spells (removed death save, haste, and general buffs)
    my @rune_spells = grep { 
        quest::IsRuneSpell($_) || quest::IsMagicRuneSpell($_)
    } @spell_list;
    
    # Sort rune spells by priority
    my @sorted_rune_spells = sort {
        my $priority_a = get_beneficial_priority($a);
        my $priority_b = get_beneficial_priority($b);
        return $priority_a <=> $priority_b;
    } @rune_spells;
    
    quest::debug("Found " . scalar(@sorted_rune_spells) . " rune spells to try");
    
    # Check if target qualifies for rune spells (below 80% HP)
    my $hp_percent = ($target->GetHP() / $target->GetMaxHP()) * 100;
    
    # Only apply runes to targets below 80% HP
    if ($hp_percent >= 80) {
        quest::debug("Target does not qualify for runes - HP: $hp_percent% (need below 80%)");
        return 0;
    }
    
    # Try rune buffs
    if (scalar(@sorted_rune_spells) > 0 && !is_swarm_member_casting_beneficial_type($target->GetID(), "rune")) {
        quest::debug("Target qualifies for runes - HP: $hp_percent%");
        foreach my $spell_id (@sorted_rune_spells) {
            if (try_cast_single_spell($target, $spell_id)) {
                return 1; # Spell was cast successfully
            }
        }
    }
    
    return 0; # No buff spell was cast
}



sub try_cast_harmful_spell {
    my ($target, @spell_list) = @_;
    
    # Skip if target is self (this NPC)
    if ($target->GetID() == $npc->GetID()) {
        quest::debug("Skipping self (NPC) as harmful spell target");
        return 0;
    }
    
    foreach my $spell_id (@spell_list) {
        # Skip spells that are on cooldown
        if ($npc->GetEntityVariable("recast_blocker_$spell_id") eq "true") {
            quest::debug("Harmful spell $spell_id is on cooldown, skipping");
            next;
        }
        
        my $spell = quest::getspell($spell_id);
        quest::debug("Checking harmful spell $spell_id on $target");
        
        # Check if the spell can be cast on the target
        my $can_cast = can_cast_harmful($target, $spell_id, $npc);
        
        if (!$can_cast) {
            quest::debug("Harmful spell $spell_id cannot be applied to target, skipping");
            next;
        }
        
        quest::debug("Casting harmful spell $spell_id on $target");
        $npc->CastSpell($spell_id, $target->GetID());
        return 1; # Indicate spell was cast
    }
    
    return 0; # No spell was cast
}

# Helper function to try casting a single spell
sub try_cast_single_spell {
    my ($target, $spell_id) = @_;
    
    # Skip if target is self (this NPC)
    if ($target->GetID() == $npc->GetID()) {
        quest::debug("Skipping spell cast on self (NPC)");
        return 0;
    }
    
    # Skip spells that are on cooldown
    if ($npc->GetEntityVariable("recast_blocker_$spell_id") eq "true") {
        quest::debug("Spell $spell_id is on cooldown, skipping");
        return 0;
    }
    
    my $spell = quest::getspell($spell_id);
    quest::debug("Checking spell $spell_id for target " . $target->GetName());
    
    # Check if the spell can be cast on the target
    my $can_cast = can_cast_beneficial($target, $spell_id, $npc);
    
    if (!$can_cast) {
        quest::debug("Spell $spell_id cannot be applied to target, skipping");
        return 0;
    }
    
    quest::debug("Casting spell $spell_id on target " . $target->GetName());
    $npc->CastSpell($spell_id, $target->GetID());
    return 1; # Indicate spell was cast
}

# Helper function with enhanced debugging to check if a target already has a specific buff
sub has_buff {
    my ($target, $spell_id) = @_;
    
    my @target_buffs = $target->GetBuffs();
    quest::debug("Checking for buff $spell_id on target " . $target->GetName() . 
                 ", found " . scalar(@target_buffs) . " buffs");
    
    # If no buffs found, return early
    if (scalar(@target_buffs) == 0) {
        quest::debug("Target has no buffs at all");
        return 0;
    }
    
    foreach my $buff (@target_buffs) {
        # Ensure buff object is valid
        if (!$buff) {
            quest::debug("Found a null buff object, skipping");
            next;
        }
        
        # Try-catch equivalent to handle potential errors
        eval {
            my $current_buff_id = $buff->GetSpellID();
            quest::debug("Comparing buff ID $current_buff_id with spell ID $spell_id");
            
            if ($current_buff_id == $spell_id) {
                quest::debug("Match found! Target has buff $spell_id");
                return 1; # Target has this buff
            }
        };
        
        if ($@) {
            quest::debug("Error checking buff: $@");
        }
    }
    
    quest::debug("Target does not have buff $spell_id");
    return 0; # Target doesn't have this buff
}

sub can_cast_beneficial {
    my ($target, $spell_id, $caster) = @_;
    
    # Get spell info
    my $spell = quest::getspell($spell_id);
    
    # Get buff duration - only apply stacking rules for spells with duration > 0
    my $buff_duration = $spell->GetBuffDuration();
    
    # If it's not a buff (duration <= 0), it's likely a heal, always allow casting
    if ($buff_duration <= 0) {
        quest::debug("Beneficial spell $spell_id is not a buff (duration = $buff_duration), can cast");
        return 1;
    }
    
    # First check: See if the exact spell already exists on the target
    my @target_buffs = $target->GetBuffs();
    foreach my $buff (@target_buffs) {
        # If it's the same spell ID
        if ($buff->GetSpellID() == $spell_id) {
            quest::debug("Beneficial spell $spell_id already exists on target");
            return 0;
        }
    }
    
    # Second check: Use CanBuffStack to see if the buff can be applied
    # Call with iFailIfOverwrite = true (1) to prevent overwriting existing buffs
    my $stack_result = $target->CanBuffStack($spell_id, $caster->GetLevel(), 1);
    quest::debug("CanBuffStack result for beneficial spell $spell_id: $stack_result");
    
    # Returns -1 on stack failure, -2 if all slots full, slot number if should overwrite, or free slot
    if ($stack_result < 0) {
        quest::debug("Beneficial spell $spell_id cannot stack on target (result: $stack_result)");
        return 0;
    }
    
    # If we made it here, the buff can be applied to the target
    quest::debug("Beneficial spell $spell_id can be cast on target");
    return 1;
}

# Function to try casting DOT spells on other mobs that are aggro on our owner
sub try_cast_dots_on_aggro_mobs {
    my ($owner, @dot_spells) = @_;
    
    # Skip if we don't have an owner
    if (!$owner) {
        quest::debug("No owner found for DOT casting on aggro mobs");
        return 0;
    }
    
    # Get all NPCs in the area
    my @potential_targets = ();
    foreach my $mob ($entity_list->GetNPCList()) {
        # Skip if it's us or our target (already tried casting on our target)
        my $current_target = $npc->GetTarget();
        if ($mob->GetID() == $npc->GetID() || 
            ($current_target && $mob->GetID() == $current_target->GetID())) {
            next;
        }
        
        # Check if this mob is aggressive towards our owner
        if ($mob->CheckAggro($owner)) {
            push(@potential_targets, $mob);
            quest::debug("Found mob " . $mob->GetName() . " (ID: " . $mob->GetID() . ") aggro on owner");
        }
    }
    
    quest::debug("Found " . scalar(@potential_targets) . " mobs aggro on owner for DOT casting");
    
    # Try to cast DOTs on each potential target
    foreach my $dot_target (@potential_targets) {
        foreach my $spell_id (@dot_spells) {
            # Skip spells that are on cooldown
            if ($npc->GetEntityVariable("recast_blocker_$spell_id") eq "true") {
                quest::debug("DOT spell $spell_id is on cooldown, skipping");
                next;
            }
            
            quest::debug("Checking DOT spell $spell_id for target " . $dot_target->GetName());
            
            # Check if the spell can be cast on the target
            my $can_cast = can_cast_harmful($dot_target, $spell_id, $npc);
            
            if (!$can_cast) {
                quest::debug("DOT spell $spell_id cannot be applied to target, skipping");
                next;
            }
            
            quest::debug("Casting DOT spell $spell_id on aggro target " . $dot_target->GetName());
            $npc->CastSpell($spell_id, $dot_target->GetID());
            return 1; # Successfully cast a DOT, done for this round
        }
    }
    
    return 0; # No DOT was cast
}

sub can_cast_harmful {
    my ($target, $spell_id, $caster) = @_;
    
    # Get spell info
    my $spell = quest::getspell($spell_id);
    
    # Get buff duration - only apply stacking rules for spells with duration > 0
    my $buff_duration = $spell->GetBuffDuration();
    
    # If it's not a buff/debuff (duration <= 0), always allow casting
    if ($buff_duration <= 0) {
        quest::debug("Harmful spell $spell_id is not a buff (duration = $buff_duration), can cast");
        return 1;
    }
    
    # Check if it's a stackable DOT
    my $is_stackable_dot = quest::IsStackableDOT($spell_id);
    
    # Get all buffs on the target
    my @target_buffs = $target->GetBuffs();
    
    # Get caster name for comparison
    my $caster_name = $caster->GetCleanName();
    
    # First check: Look for the exact spell on the target
    foreach my $buff (@target_buffs) {
        # If it's the same spell ID
        if ($buff->GetSpellID() == $spell_id) {
            if ($is_stackable_dot) {
                # For stackable DOTs, check if WE already have one on the target
                quest::debug("Caster Compare: " . $buff->GetCasterName() . " vs " . $caster_name);
                if ($buff->GetCasterName() eq $caster_name) {
                    quest::debug("We already have this stackable DOT on the target, skipping");
                    return 0;
                }
                # If it's from another caster, continue with the stack check
            } else {
                # Non-stackable spell already exists on target, regardless of caster
                quest::debug("Non-stackable harmful spell already exists on target");
                return 0;
            }
        }
    }
    
    # Second check: Use CanBuffStack to see if the debuff can be applied
    # Call with iFailIfOverwrite = true (1) to prevent overwriting existing buffs
    my $stack_result = $target->CanBuffStack($spell_id, $caster->GetLevel(), 1);
    quest::debug("CanBuffStack result for harmful spell $spell_id: $stack_result");
    
    # Returns -1 on stack failure, -2 if all slots full, slot number if should overwrite, or free slot
    if ($stack_result < 0) {
        quest::debug("Harmful spell $spell_id cannot stack on target (result: $stack_result)");
        return 0;
    }
    
    # If we made it here, either:
    # 1. The spell doesn't exist on the target, or
    # 2. It's a stackable DOT and we don't have our instance on the target yet
    # And the CanBuffStack check has passed
    quest::debug("Harmful spell $spell_id can be cast on target");
    return 1;
}

###########################################
## Swarm Positioning Logic
###########################################

# Time interval between position updates (in seconds)
my $POSITION_UPDATE_INTERVAL = 5;

# Distance to maintain from the target (in game units)
my $OPTIMAL_ATTACK_DISTANCE = 10;

# Function to handle position coordination among swarm members
sub EVENT_SPAWN {
    $npc->SetTimer("cast_check", 1);
    $npc->SetTimer("spell_interrupt_check", $SPELL_INTERRUPT_CHECK_INTERVAL);
    $npc->SetTimer("position_update", $POSITION_UPDATE_INTERVAL);
}

sub EVENT_TIMER {
    if ($timer eq "cast_check") {
        handle_cast_check();
    } elsif ($timer eq "spell_interrupt_check") {
        check_and_interrupt_spell();
    } elsif ($timer eq "position_update") {
        handle_swarm_positioning();
    } elsif ($timer =~ /^recast_blocker_expire_(\d+)$/) {
        my $spell_id = $1;
        quest::debug("Cooldown expired for spell $spell_id");
        $npc->DeleteEntityVariable("recast_blocker_$spell_id");
        $npc->StopTimer($timer);
    } elsif ($timer eq "global_cooldown_expire") {
        quest::debug("Global cooldown expired");
        $npc->DeleteEntityVariable("global_cooldown");
        $npc->StopTimer($timer);
    }
}

# Function to position swarm members equidistantly around target
sub handle_swarm_positioning {
    # Get necessary references
    my $target = $npc->GetTarget();
    my $owner_id = $npc->GetSwarmOwner();
    my $npc_type_id = $npc->GetNPCTypeID();
    
    # Skip if we don't have a target or owner
    if (!$target || !$owner_id) {
        return;
    }
    
    # Find all NPCs of our type that belong to the same owner
    my @swarm_members = ();
    foreach my $potential_member ($entity_list->GetNPCList()) {
        if ($potential_member && 
            $potential_member->GetNPCTypeID() == $npc_type_id &&
            $potential_member->GetSwarmOwner() == $owner_id) {
            push(@swarm_members, $potential_member);
        }
    }
    
    # If we're the only member, no need to coordinate positions
    my $swarm_size = scalar(@swarm_members);
    if ($swarm_size <= 1) {
        return;
    }
    
    quest::debug("Found $swarm_size swarm members to coordinate positions");
    
    # Sort swarm members by their ID to ensure consistent ordering
    @swarm_members = sort { $a->GetID() <=> $b->GetID() } @swarm_members;
    
    # Find our index in the sorted list
    my $my_id = $npc->GetID();
    my $my_index = -1;
    for (my $i = 0; $i < $swarm_size; $i++) {
        if ($swarm_members[$i]->GetID() == $my_id) {
            $my_index = $i;
            last;
        }
    }
    
    # If we couldn't find ourselves in the list (shouldn't happen), exit
    if ($my_index == -1) {
        quest::debug("Could not find self in swarm members list, position update aborted");
        return;
    }
    
    quest::debug("My position in the swarm: $my_index of $swarm_size");
    
    # Calculate heading for this NPC based on its position in the swarm
    # EQ heading system: 0-512 where 0=North, 128=East, 256=South, 384=West
    my $heading_step = 512 / $swarm_size;
    my $eq_heading = ($my_index * $heading_step) % 512;
    
    # Convert EQ heading to radians for trigonometry
    # EQ heading 0 = North = -π/2 radians (negative Y direction)
    # EQ heading increases clockwise
    my $angle_radians = (($eq_heading / 512) * 2 * 3.14159) - (3.14159 / 2);
    
    # Get target position
    my $target_x = $target->GetX();
    my $target_y = $target->GetY();
    my $target_z = $target->GetZ();
    
    # Calculate new position around the target
    my $new_x = $target_x + ($OPTIMAL_ATTACK_DISTANCE * cos($angle_radians));
    my $new_y = $target_y + ($OPTIMAL_ATTACK_DISTANCE * sin($angle_radians));
    
    # Try to use the target's Z coordinate, but adjust if necessary
    # This helps keep NPCs at the same height as the target
    my $new_z = $target_z;
    
    quest::debug("Moving to position $my_index of $swarm_size at EQ heading $eq_heading (" . ($eq_heading * 360 / 512) . " degrees)");
    quest::debug("New coordinates: X=$new_x, Y=$new_y, Z=$new_z");
    
    # Use navpath or pathing function if available for better navigation
    if ($npc->can('PathingTo')) {
        $npc->PathingTo($new_x, $new_y, $new_z);
    } else {
        # Fallback to basic movement if advanced pathing isn't available
        $npc->MoveTo($new_x, $new_y, $new_z, 0, 1);
    }
}
