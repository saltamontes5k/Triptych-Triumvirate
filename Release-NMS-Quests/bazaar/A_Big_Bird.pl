sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
    if (!plugin::IsNMS()) {
        return;
    }

    my $remove_class_cost = 10;
    my $reset_aa_cost = 5;
    my $remove_class_lockout = 7;

    if ($text=~/hail/i) {
        if (plugin::GetClassesCount($client) <= 1) {
            plugin::NPCTell("Ah. A new arrival. I would offer encouragement, but the wilderness will strip that off you in your first ten minutes. If you would rather leave your fate to chance - and chance is cruel - I offer the [pull of the sky].");
        } else {
            plugin::NPCTell("You again. More classes than sense, which is at least a start. I can [reshape your flight], if you have given up on doing it yourself.");
        }

        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove) {
            plugin::YellowText("You have a free class removal available. You will be given the option to use it by proceeding with the menu.");
        }

        my $free_aa_reset_used = ($client->GetBucket("free_aa_reset_used") || 0);
        if (!$free_aa_reset_used) {
            plugin::YellowText("You have a free AA Reset available. You will be given the option to use it by proceeding with the menu.");
        }

        return;
    }

    if ($text=~/pull of the sky/i) {
        if (plugin::GetClassesCount($client) == 1) {
            plugin::NPCTell("You will be assigned three classes at random, and no, you do not get to pick. Think of it as an adventure, or a mistake - the game has never distinguished the two. Are you certain that you wish to do this?");
            plugin::YellowText("WARNING: If you [".quest::saylink('randomize_me_soul', 1, 'continue')."], you will be assigned three random classes. This decision cannot be reversed.");
        } else {
            plugin::NPCTell("You already have your classes. There is nothing here for you but regret. Move along.");
        }
        return;
    }

    if ($text=~/randomize_me_soul/i) {

        if (plugin::GetClassesCount($client) == 1) {
            my @all_classes = (1..16);

            # Store the client's original class
            my $original_class_id = 0;

            # Find the original class ID by checking each possible class
            for my $class_id (1..16) {
                if (plugin::HasClass($client, $class_id)) {
                    $original_class_id = $class_id;
                    last;
                }
            }

            # Add two random classes first
            my $classes_added = 0;
            while ($classes_added < 2) {
                my $random_class = $all_classes[int(rand(@all_classes))];

                # Make sure we don't add the original class or a class we already added
                if (!plugin::HasClass($client, $random_class)) {
                    plugin::AddClass($random_class, $client);
                    $classes_added++;
                }
            }

            # Now remove the original class
            plugin::RemoveClass($original_class_id, $client);

            # Add a third random class
            while (plugin::GetClassesCount($client) < 3) {
                my $random_class = $all_classes[int(rand(@all_classes))];

                # Make sure we don't add a class we already have
                if (!plugin::HasClass($client, $random_class)) {
                    plugin::AddClass($random_class, $client);
                }
            }

            my $full_class_name = plugin::GetPrettyClassString($client);

            plugin::WorldAnnounce("$name surrendered all choice and received: ($full_class_name). Congratulations, probably.");
            plugin::NPCTell("There. Done. Go and use your new classes boldly - or at least memorably.");
        } else {
            plugin::NPCTell("You already have your classes. There is nothing here for you but regret. Move along.");
        }
        return;
    }

    if ($text=~/free_reset_aa/i) {
        my $free_aa_reset_used = ($client->GetBucket("free_aa_reset_used") || 0);
        if (!$free_aa_reset_used) {
            plugin::YellowText("All of your AA have been refunded.");
            $client->SetBucket("free_aa_reset_used", 1);
            $client->ResetAA();
            plugin::CommonCharacterUpdate($client);
            $client->Save(1);
        }
    }

    if ($text=~/reshape your flight/i) {
        if (plugin::GetClassesCount > 1) {
            my $classes_string = GetClassLinkString();

            plugin::NPCTell(
                "Yes, I am a big bird. No, I will not explain it. I remove classes, reset abilities, and adjust levels - the only honest work in this bazaar, since everything here is just a way to die slightly differently.\n\n"
            . "Pick a class to abandon: $classes_string.\n\n"
            . "Or perhaps you would prefer me to ["
            . quest::saylink("reset_aa", 1, "restore and reallocate your alternate advancement abilities")
            . "] - a full refund of every ability point, no questions asked.\n\n"
            . "And if you want to skip the journey entirely, I will ["
            . quest::saylink("adjust_level", 1, "adjust your level")
            . "] for 500 platinum pieces per level - cash up front, obviously."
            );
        }
    }

    if ($text=~/adjust_level/i) {
        my $stored_level = $client->GetBucket("MaxLevelAchieved") || 0;

        # Update stored level if the current level exceeds it
        if ($client->GetLevel() > $stored_level) {
            $stored_level = $client->GetLevel();
            $client->SetBucket("MaxLevelAchieved", $stored_level);
        }

        my $current_level = $client->GetLevel();
        my @level_options;

        # Generate level options excluding the player's current level
        for (my $level = 5; $level <= $stored_level; $level += 5) {
            next if $level == $current_level;
            push @level_options, "[" . quest::saylink("set_level_$level", 1, "Level $level") . "]";
        }

        my $options_string = join(", ", @level_options);
        plugin::NPCTell(
            "Level adjustments cost 500 platinum pieces per level changed, payable in advance. "
        . "The levels I sell: $options_string. "
        . "Choose quickly - I have other customers, and none of them are interesting either."
        );
    }

    if ($text=~/set_level_(\d+)/i) {
        my $desired_level = $1;
        my $stored_level = $client->GetBucket("MaxLevelAchieved") || 0;

        if ($desired_level > 0 && $desired_level <= $stored_level) {
            my $current_level = $client->GetLevel();
            my $level_difference = abs($current_level - $desired_level);
            my $cost_in_platinum = $level_difference * 500;

            # Display YellowText confirmation for level change
            if ($level_difference == 0) {
                plugin::YellowText(
                    "You have selected your current level ($current_level). An excellent choice - it costs nothing and changes nothing."
                );
            } else {
                plugin::YellowText(
                    "Changing your level to $desired_level will cost $cost_in_platinum platinum pieces. "
                . "Would you like to ["
                . quest::saylink("confirm_level_change_$desired_level", 1, "confirm this adjustment")
                . "]?"
                );
            }
        } else {
            plugin::NPCTell(
                "That level is not on the menu. Pick one I actually offered."
            );
        }
    }

    if ($text=~/confirm_level_change_(\d+)/i) {
        my $desired_level = $1;
        my $stored_level = $client->GetBucket("MaxLevelAchieved") || 0;

        if ($desired_level > 0 && $desired_level <= $stored_level) {
            my $current_level = $client->GetLevel();
            my $level_difference = abs($current_level - $desired_level);
            my $cost_in_copper = $level_difference * 500 * 1000; # Convert platinum to copper (1 platinum = 1000 copper)
            my $cost_in_platinum = $level_difference * 500;

            if ($level_difference == 0) {
                plugin::NPCTell(
                    "You remain at Level $current_level. No changes were made, and no platinum was harmed. "
                . "Come back when you mean it."
                );
            } elsif ($client->TakeMoneyFromPP($cost_in_copper, 1)) {
                plugin::YellowText("You spent $cost_in_platinum platinum pieces.");
                $client->SetLevel($desired_level,1);
                plugin::NPCTell(
                    "Your level has been adjusted to $desired_level for a cost of $cost_in_platinum platinum pieces. "
                . "Whether that was wise is now your problem."
                );

                if ($desired_level < $current_level) {
                    $client->UnmemSpellAll(1);
                    $client->BuffFadeAll();
                }
            } else {
                plugin::NPCTell(
                    "Your resources are insufficient for such an adjustment. You require $cost_in_platinum platinum pieces "
                . "to proceed. Come back when your purse matches your ambition."
                );
            }
        } else {
            plugin::NPCTell(
                "That level is not on the menu. Pick one I actually offered."
            );
        }
    }

    if ($text eq 'reset_aa') {
        my $free_aa_reset_used = ($client->GetBucket("free_aa_reset_used") || 0);
        if (!$free_aa_reset_used) {
            plugin::YellowText("You have a free AA Reset available. Would you like to [".quest::saylink("free_reset_aa", 1, "use it")."]?");
        }

        if (plugin::GetTriuneOfFate($client) >= $reset_aa_cost) {
                plugin::YellowText("It will cost $reset_aa_cost Triune of Fate in order to reset your AA. Would you like to ["
                                .quest::saylink("confirm_reset_aa", 1, "Proceed")."]?");

        } else {
                plugin::YellowText("It costs $reset_aa_cost Triune of Fate in order to reset your AA. You can obtain
                                Triune of Fate through contributions to the server or purchase from other players in the Bazaar.");
        }
    }

    if ($text eq 'confirm_reset_aa') {
        if (plugin::SpendTriuneOfFate($client, $reset_aa_cost)) {
            plugin::YellowText("All of your AA have been refunded.");
            $client->ResetAA();
            plugin::CommonCharacterUpdate($client);
            $client->Save(1);
        }
    }

    if ($text =~ /^del_class_(\d+)$/i) {
        my $class_id = $1;

        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove) {
            plugin::YellowText("You have a free class removal available. Would you like to [".quest::saylink("free_$class_id", 1, "use it")."]? This will bypass any lockouts or costs.");
        } else {
            if ($client->HasExpeditionLockout("Class Removal Lockout", "")) {
                plugin::YellowText("You cannot remove a class at this time, you still are under cooldown from a previous class removal.");
                return 0;
            }
        }

        if (plugin::HasClass($client, $class_id)) {
            if (plugin::GetTriuneOfFate($client) >= $remove_class_cost) {
                 plugin::YellowText("It will cost $remove_class_cost Triune of Fate in order to remove a class. Additionally,
                                    there is a $remove_class_lockout-day cooldown after removing a class before you can remove another.
                                    Would you like to [".quest::saylink("proceed_$class_id", 1, "Proceed")."]?");

            } else {
                 plugin::YellowText("It costs $remove_class_cost Triune of Fate in order to remove a class. You can obtain
                                    Triune of Fate through contributions to the server or purchase from other players in the Bazaar.");
            }
        }
    }

    if ($text =~ /^proceed_(\d+)$/i) {
        #return;
        my $class_id = $1;

        if ($client->HasExpeditionLockout("Class Removal Lockout", "")) {
            plugin::YellowText("You cannot remove a class at this time, you still are under cooldown from a previous class removal.");
            return 0;
        }

        if (!$client->HasExpeditionLockout("Class Removal Lockout", "") && plugin::HasClass($client, $class_id)) {
            if (plugin::SpendTriuneOfFate($client, $remove_class_cost)) {
                plugin::RemoveClass($class_id, $client);
                $client->AddExpeditionLockout("Class Removal Lockout", "", $remove_class_lockout * 24 * 60 * 60);
            }
        }
    }

    if ($text =~ /^free_(\d+)$/i) {
        #return;
        my $class_id = $1;
        my $free_class_remove = ($client->GetBucket("free_remove_class_used") || 0);
        if (!$free_class_remove && plugin::HasClass($client, $class_id)) {
            plugin::RemoveClass($class_id, $client);
            $client->SetBucket("free_remove_class_used", 1);
        }
    }

    if ($text =~ /unmem/i) {
        for ($i = 0; $i < 12; $i++) {
            $client->UnmemSpell($i, 1);
        }
    }
}

sub GetClassLinkString {
    my $client = shift || plugin::val('$client');  # Ensure $client is available
    my %class_map = plugin::GetClassMap();  # Get the full class map
    my $class_bits = $client->GetClassesBitmask();  # Retrieve the class bits for the client

    my @client_classes;

    # Iterate through class IDs to check which classes the client has
    foreach my $class_id (sort { $a <=> $b } keys %class_map) {
        if ($class_bits & (1 << ($class_id - 1))) {
            push @client_classes, "[".quest::saylink("del_class_$class_id", 1, $class_map{$class_id})."]";
        }
    }

    # Join the client's class names, using ", " and " or " appropriately
    my $pretty_class_string;
    if (@client_classes > 1) {
        $pretty_class_string = join(', ', @client_classes[0..$#client_classes-1]) . ' or ' . $client_classes[-1];
    } else {
        $pretty_class_string = $client_classes[0];  # Only one class
    }

    return $pretty_class_string;
}
