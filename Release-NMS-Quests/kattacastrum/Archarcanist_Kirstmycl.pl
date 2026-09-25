sub EVENT_SAY {
    my $stage = $qglobals{portal_task} || 0;
    if ($text =~ /Hail/i) {
        if ($stage == 0) {
            quest::say("Hail, traveler. The portals of Katta Castrum are sealed. I am Archarcanist Kirstmycl. Say 'Give me instructions' to begin your task.");
        } elsif ($stage == 1) {
            quest::say("You have activated the Sanctuary portals! Say 'The next set?' when you are ready for the next challenge.");
        } elsif ($stage == 2) {
            quest::say("The Dangerous Ground portals are now active. Say 'Instructions' for the final task.");
        } else {
            quest::say("All of Katta Castrum's portals are now at your disposal!");
        }
    } elsif ($text =~ /Give me instructions/i) {
        if ($stage == 0) {
            quest::assigntask(600221);
            quest::updatetaskactivity(600221, 0, 1);
            quest::say("You must collect nine portal keys from the ziggurats around Katta Castrum. Slay the Chaotic Manifestations that guard the ziggurats and their keys will appear in your hands. Return to me when you have all nine.");
        } else {
            quest::say("You already walk that path, traveler.");
        }
    } elsif ($text =~ /The next set\?/i) {
        if ($stage == 1) {
            quest::assigntask(600222);
            quest::updatetaskactivity(600222, 0, 1);
            quest::say("Good work on the Sanctuary portals. Now for the Dangerous Ground task. Collect twelve more keys and defeat twelve shissars. Return to me when complete.");
        } else {
            quest::say("One step at a time. Finish the Sanctuary portals first.");
        }
    } elsif ($text =~ /Instructions/i) {
        if ($stage == 2) {
            if (!$qglobals{portal_wand}) {
                quest::summonitem(32895);
                quest::setglobal("portal_wand", 1, 7, "F");
            }
            quest::assigntask(600223);
            quest::updatetaskactivity(600223, 0, 1);
            quest::say("Take this Wand of Portal Stabilization. It has twenty charges of Stabilize Portal. Use it at the ziggurats on the outer ring. Defeat the manifestations and collect the keys. Return to me when complete.");
        } else {
            quest::say("You are not yet ready for the War Torn Portals.");
        }
    }
}

sub EVENT_ITEM {
    my $stage = $qglobals{portal_task} || 0;
    my %key_sets = (
        0 => [32865, 32866, 32867, 32868, 32869, 32870, 32871, 32872, 32873],
        1 => [32874, 32875, 32876, 32877, 32878, 32879, 32880, 32881, 32882, 32883, 32884, 32885],
        2 => [32866, 32886, 32887, 32889, 32890, 32891, 32892, 32893, 32894]
    );
    my %goals  = (0 => 9,  1 => 12, 2 => 9);
    my %tasks  = (0 => 600221, 1 => 600222, 2 => 600223);
    my %finals = (0 => 10, 1 => 14, 2 => 11);
    my $task = $tasks{$stage};
    my $turned_in = 0;
    if (quest::istaskactive($task)) {
        foreach my $key_id (@{$key_sets{$stage}}) {
            if ($itemcount{$key_id}) {
                delete $itemcount{$key_id};
                $turned_in++;
            }
        }
    }
    if ($turned_in > 0) {
        my $gname = "portal_keys_" . $stage;
        my $total = ($qglobals{$gname} || 0) + $turned_in;
        quest::setglobal($gname, $total, 7, "F");
        if ($total >= $goals{$stage}) {
            quest::updatetaskactivity($task, $finals{$stage}, 1);
            quest::setglobal("portal_task", $stage + 1, 7, "F");
            if ($stage == 0) {
                quest::say("Excellent! You have collected all nine Sanctuary portal keys. The Sanctuary portals are now active!");
            } elsif ($stage == 1) {
                quest::say("Wonderful! You have collected all twelve Dangerous Ground portal keys and defeated the shissars. The Dangerous Ground portals are now active!");
            } else {
                quest::say("Incredible! You have activated all the War Torn Portals! All of Katta Castrum's portals are now at your disposal!");
            }
        } else {
            quest::say("I count " . $total . " of " . $goals{$stage} . " keys. Bring me the rest and defeat the shissar guardians.");
        }
    }
    foreach my $itm (keys %itemcount) {
        my $count = $itemcount{$itm};
        while ($count > 0) {
            quest::summonitem($itm, 1);
            $count--;
        }
    }
}
