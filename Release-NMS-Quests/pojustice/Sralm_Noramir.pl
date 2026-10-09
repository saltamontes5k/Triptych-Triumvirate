###############################################
# Name:  Sralm Noramir
# Zone:  Plane of Justice
# Author:  Andrew80k
###############################################
sub EVENT_SAY {
  if ($text=~/hail/i) {
     quest::emote("pounces at you, grabbing you by your throat.");
     quest::say("What are you doing here? Who sent you?");
  }
  elsif ($text=~/no one.*sent me/i) {
     quest::say("I hope you are not here to free a prisoner. The Tribunal punishes such actions harshly. Once here there is no hope of escape. Even for one such as I.");
  }
  elsif ($text=~/sent me/i) {
     quest::say("Hmm, that name is not familiar to me.  You must be in the wrong place.  Begone before I wear your hide to keep myself warm.");
  }
  elsif ($text=~/who are you/i || $text=~/such as i/i) {
     quest::say("Ahh, how rude of me. Allow me to introduce myself. I am Sralm Noramir, warrior by birth thief by choice.");
  }
  elsif ($text=~/thief/i) {
     quest::say("Aye, I could steal the sword from a warriors hands or a kiss from a ladys lips. Ever hear of Emperor Sllanar?");
  }
  elsif ($text=~/sllanar/i) {
     quest::say("He was the ruler of Sebilis, for a short time.  It does not surprise me that you have not heard of him.  His rule was not long, and he did little good or bad for the iksar.  He was, however, quite [wealthy].");
  }
  elsif ($text=~/wealthy/i) {
     quest::say("Quite wealthy, indeed.  More money than you could ever imagine, but it was just as much as I could imagine.  I felt that the good Emperor had more wealth than he could possibly ever spend, so I thought it was my duty to [relieve] him of some of the excess.");
  }
  elsif ($text=~/relieve/i) {
     quest::say("Yes, and quite a job it was.  He kept all of his accumulated wealth in caves deep below the city.  Though they were well guarded, it was nothing for one such as myself.  I will not bore you with details, but the short of it is I made off with a king's ransom... Literally.  Unfortunately, I was [caught].");
  }
  elsif ($text=~/caught/i) {
     quest::emote("sighs, 'It seems the good Emperor was quite paranoid, and took precautions against this contingency.  All of his wealth was enchanted by a tracking spell.  It was silly of me not to look for it.  Stealing was a minor crime in Sebilis, but stealing from the [Emperor] was another issue all its own.'");
  }
  elsif ($text=~/emperor/i || $text=~/never heard/i) {
     quest::say("You see, generally thieves were imprisoned, or at worst executed, but banishment here was usually reserved to those that committed heinous crimes. I guess you should be careful when you rob the person who gets to decide on the definition of heinous. Have you any news of [Sebilis]?");
  }
  elsif ($text=~/sebilis/i) {
     quest::say("Sebilis is the city of the Iksar.  The greatest city on all of Kunark, and was my home at one time.  I guess no news is good news.");
  }
  elsif ($text=~/trakanon.*dragon/i || $text=~/dragon.*trakanon/i) {
     quest::say("A dragon in Sebilis! Stop your foul lies, your humor does not suit my tastes.");
  }
  elsif ($text=~/trakanon/i) {
     quest::say("What in the name of Thule is a Trakanon?");
  }
  elsif ($text=~/dragon/i) {
     quest::say("A dragon in Sebilis! Stop your foul lies, your humor does not suit my tastes.");
  }
  elsif ($text=~/froglok/i) {
     quest::say("This can't be real! Frogloks in Sebilis, my ancestral home. My how the mighty has fallen. I guess I was better off here after all.");
  }
  elsif ($text=~/who am i/i) {
     quest::say("Well, assuming the question is as silly as it sounds, you are $name.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}