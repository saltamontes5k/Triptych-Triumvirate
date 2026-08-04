sub EVENT_SAY {
    if ($faction <= 6) {
        if ($text =~ /hail/i) {
            quest::say("Hmm, I have been watching you. You made it further than I thought you would. I will have to work on my defenses in the future. So, what do you seek of me?");
        }
        elsif ($text =~ /Jaled/i) {
            quest::say("Jaled Dar is quite dead, you know. But he was tasty, I feasted on his remains long ago. I do wish his spirit would go away, his incessant wailing disturbs me, and worse, it makes other dragons wary of this place. I have not eaten as well as I would have liked since his shade came to stay. If you wish to speak with him yourself, I can arrange that, for I hold a key that will unlock his tomb.");
        }
        elsif ($text =~ /key/i) {
            quest::say("This IS my realm, after all. Nothing is barred to me. But I did not become who I am by doing something for nothing. If you wish to talk to Jaled Dar, you will have to do something for me first. Are you willing to do this task?");
        }
        elsif ($text =~ /task/i) {
            quest::say("There is an annoying uprising taking place among the Chetari and Paebala. This is affecting my diet. I get cranky when I don't eat right. I am VERY cranky right now. The rebellion is led by a Paebala named Neb. He has taken his followers into a part of the Necropolis that I have difficulty reaching, and he has somehow tamed the goo there as well, preventing my Chetari followers from assaulting them directly. If Neb were to fall, I am certain the rebellion would quickly falter. Bring me Neb's head, and I will give you the key to Jaled Dar's tomb.");
        }
        elsif ($text =~ /harla/i) {
            quest::say("I know that name.  Oh, that pest Jaled Dar mentions it from time to time.  And there was... yes, I think that is it.  I dined upon a young purple recently, which the Chetari had captured for me.  He called out the name Harla Dar as well.  I am still digesting him, as a matter of fact.");
        }
        elsif ($text =~ /claws of veeshan/i) {
            quest::say("The Claws of Veeshan? They are delicious!  They still do not know that it was MY idea to create the Necropolis, to insure a steady supply of food.  They are bound by tradition, and tradition says that all dragons should come here to die.  Fools, of course, but who am I to complain?");
        }
        elsif ($text =~ /vaniki/i) {
            quest::say("Vaniki is my child, so to speak.  She and all of the Chetari are my creations.  I uplifted them from the Paebala.  They are smarter, larger, stronger than their cousins.  And I taught them the dark ways.   They serve me well, bringing me food, and are my eyes and ears outside of this place.");
        }
    }
    else {
        quest::say("I didn't know Slime could speak common.  Go back to the sewer before I lose my temper.");
    }
}

sub EVENT_ITEM {
#    quest::ze(2,"Your faction is $faction");
    if ($faction <= 6) { #apprensive or better
#        quest::ze(2,"Your faction was high enough.");
        if (plugin::check_handin(\%itemcount, 26010, => 1)) {
#            quest::ze(2,"You handed in the right item.");
            quest::summonitem(28060);   #JD Tomb Key
            quest::say("Excellent work! Here is your key, go bother that prattling fool Jaled Dar, and leave me be.");
            quest::faction(462, 50);    #Positive Chetari
            quest::faction(464, 500);   #Positive Zlandicar
            quest::faction(430, -50);   #Negative Claws of Veeshan
            quest::faction(304, -50);   #Negative Ring of Scale
            quest::exp(250000);
        }
    }
    plugin::return_items(\%itemcount);
}

sub EVENT_DEATH_COMPLETE {
    plugin::handle_death($npc, $x, $y, $z, $entity_list);
    my $killer = $entity_list->GetClientByID($killer_id);   
    if ($killer && int(rand(100)) == 0) {
        plugin::AddTitleFlag(200);
    }
}