# items: 32865, 32866, 32867, 32868, 32869, 32870, 32871, 32872, 32873, 32874, 32875, 32876, 32877, 32878, 32879, 32880, 32881, 32882, 32883, 32884, 32885, 32886, 32887, 32888, 32889, 32890, 32891, 32892, 32893, 32894, 32895
sub EVENT_SAY {
    if ($text =~ /Hail/i) {
        if (defined $qglobals{portal_task}) {
            if ($qglobals{portal_task} == 1) {
                quest::say("You have activated the Sanctuary portals! Return to me when you are ready for the next challenge.");
            } elsif ($qglobals{portal_task} == 2) {
                quest::say("The Dangerous Ground portals are now active. Return to me for the final task.");
            } elsif ($qglobals{portal_task} == 3) {
                quest::say("All of Katta Castrum's portals are now at your disposal!");
            }
        } else {
            quest::say("Hail, traveler. The portals of Katta Castrum are sealed. I am Archarcanist Kirstmycl. Say 'Give me instructions' to begin your task.");
        }
    } elsif ($text =~ /Give me instructions/i) {
        quest::assigntask(600221);
        quest::say("You must collect nine portal keys from the ziggurats around Katta Castrum. The keys are at the Sanctuary, Inner, and Outer rings. Approach each ziggurat and the key will appear. Return to me when you have all nine.");
    } elsif ($text =~ /The next set\?/i) {
        quest::assigntask(600222);
        quest::say("Good work on the Sanctuary portals. Now for the Dangerous Ground task. Collect twelve more keys and defeat twelve Shissars. Return to me when complete.");
    } elsif ($text =~ /Instructions/i) {
        quest::summonitem(32895);
        quest::assigntask(600223);
        quest::say("Take this Wand of Portal Stabilization. It has twenty charges of Stabilize Portal. Use it at the ziggurats on the outer ring. Defeat the manifestations and collect the keys. Return to me when complete.");
    }
}

sub EVENT_ITEM {
    if (plugin::check_handin(\%itemcount, 32865 => 1, 32866 => 1, 32867 => 1, 32868 => 1, 32869 => 1, 32870 => 1, 32871 => 1, 32872 => 1, 32873 => 1)) {
        quest::taskcomplete(600221);
        quest::say("Excellent! You have collected all nine Sanctuary portal keys. The Sanctuary portals are now active!");
        quest::setglobal("portal_task", "1", 7, "F");
        plugin::return_items(\%itemcount);
        return;
    }
    if (plugin::check_handin(\%itemcount, 32874 => 1, 32875 => 1, 32876 => 1, 32877 => 1, 32878 => 1, 32879 => 1, 32880 => 1, 32881 => 1, 32882 => 1, 32883 => 1, 32884 => 1, 32885 => 1)) {
        quest::taskcomplete(600222);
        quest::say("Wonderful! You have collected all twelve Dangerous Ground portal keys and defeated the Shissars. The Dangerous Ground portals are now active!");
        quest::setglobal("portal_task", "2", 7, "F");
        plugin::return_items(\%itemcount);
        return;
    }
    if (plugin::check_handin(\%itemcount, 32866 => 1, 32886 => 1, 32887 => 1, 32889 => 1, 32890 => 1, 32891 => 1, 32892 => 1, 32893 => 1, 32894 => 1)) {
        quest::taskcomplete(600223);
        quest::say("Incredible! You have activated all the War Torn Portals! All of Katta Castrum's portals are now at your disposal!");
        quest::setglobal("portal_task", "3", 7, "F");
        plugin::return_items(\%itemcount);
        return;
    }
    plugin::return_items(\%itemcount);
}
