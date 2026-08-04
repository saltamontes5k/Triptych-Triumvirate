# items: 14794, 14791, 14792, 14793, 14813, 3064, 4983, 14808, 3061, 4980, 14831, 3063, 4982, 14809, 3062, 4981
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::emote("sighs heavily and after a long while says, 'Leave us, Iksar. Leave us to our eternal damnation.'");
    return;
  }
  if ($text=~/curse/i) {
    quest::emote("twists his face into a frown");
    quest::say("You read what's written, Iksar. It's clear enough so we won't bother to explain the details. We can only stand our guard and hope for [redemption].");
    return;
  }
  if ($text=~/redemption/i) {
    quest::emote("grits his teeth and snaps");
    quest::say("It's very simple, Syriash! We are fallen! We seek redemption! We guard our 'brothers' here among the Howling Stones until we are relieved. Whether that will ever happen, we do not know. We can only hope that by providing the great warriors of the legion with our [ancient armor], we will earn salvation.");
    return;
  }
  if ($text=~/ancient armor/i) {
    quest::say("You wish the armor of our ancestors? The armor donned by the Guard whose duty was to protect the Chosen? A warrior relies not on strength alone, but many virtues. If a warrior learns to balance each virtue, then he may be fit to guard the Chosen. Each piece of armor reflects a [virtue], and each virtue must be learned before the armor is given.");
    return;
  }
  if ($text=~/virtue/i) {
    quest::say("The virtues symbolized by the armor I keep are confidence and righteousness. The [boots], [greaves], [gauntlets], and [bracers]. Bring me proof that you have mastered these virtues as well as a piece of Banded armor of the type you desire and the appropriate armor shall be yours, Syriash. If you wish the other pieces you must speak to my brother.");
    return;
  }
  if ($text=~/boots/i) {
    quest::say("You wish the boots worn by the ancients? Then you must first master the virtue of confidence. For our brothers of the dead, confidence is the virtue that allows them to control the forces that would tear them apart if they knew it not. When a warrior steps, he must be confident, for a weak step cannot crush your enemies. Take this note to the current Harbinger in Cabilis and learn from him.");
    quest::summonitem(14794); # Item: Illegible Note: Boots
    return;
  }
  if ($text=~/bracer/i) {
    quest::say("The bracers of our ancestors embody righteousness. When we strike, and our forearms are soaked in the blood of our enemies, our purpose must be pure. Else that blood will burn our souls and anger that which we live for. Go and find the Archduke in Cabilis and give him my note. He will teach you of righteousness. For if our chosen did not know righteousness, our people would not be. Go!");
    quest::summonitem(14791); # Item: Illegible Note: Bracer
    return;
  }
  if ($text=~/gauntlets/i) {
    quest::say("Our hands are our most useful and deadly instruments, after our minds. When we use them other than in service of our lord and ancestors, our actions are false. Without knowing righteousness we can never be sure if our actions are in the name of fear. The Chosen, the Crusaders of Greenmist, know fear intimately. Their actions are never without the blessing of our lord. Take this note to the Archduke. He will recognize my writing and instruct you.");
    quest::summonitem(14792); # Item: Illegible Note: Gauntlets
    return;
  }
  if ($text=~/greaves/i) {
    quest::say("Our legs move us forward. If we move with hesitance we will surely fall and leave our charge exposed. Before you can wear the greaves, you must learn from the Brood of Kotiz. For if they did not wield their powers over the dead with confidence, their life forces would be sucked from them instantly, leaving them empty husks. Take this note to the Harbinger and listen to his instructions.");
    quest::summonitem(14793); # Item: Illegible Note: Greaves
    return;
  }
}
  
sub EVENT_ITEM {
  if (quest::handin({ 14813 =>1, 3064 =>1 })) {
    quest::emote("takes the note in his pincers carefully and looks it over. After a moment he bows his head, closing his eyes. You lapse into unconciousness for a second and when your eyes open you are still standing, although now holding your new legionnaire scale boots!");
    quest::summonitem(4983); # Item: Trooper Scale Boots
    quest::ding();
    quest::exp(10000);
  }  
  if (quest::handin({ 14808 =>1, 3061 =>1 })) {
    quest::emote("takes the note in his pincers carefully and looks it over. After a moment he bows his head, closing his eyes. You lapse into unconciousness for a second and when your eyes open you are still standing, although now holding your new legionnaire scale bracer!");
    quest::summonitem(4980); # Item: Trooper Scale Bracers
    quest::ding();
    quest::exp(10000);
  }
  if (quest::handin({ 14831 =>1, 3063 =>1 })) {
    quest::emote("takes the note in his pincers carefully and looks it over. After a moment he bows his head, closing his eyes. You lapse into unconciousness for a second and when your eyes open you are still standing, although now holding your new legionnaire scale greaves!");
    quest::summonitem(4982); # Item: Trooper Scale Greaves
    quest::ding();
    quest::exp(10000);
   }
   if (quest::handin({ 14809 =>1, 3062 =>1 })) {
    quest::emote("takes the note in his pincers carefully and looks it over. After a moment he bows his head, closing his eyes. You lapse into unconciousness for a second and when your eyes open you are still standing, although now holding your new legionnaire scale gauntlets!");
    quest::summonitem(4981); # Item: Trooper Scale Gauntlets
    quest::ding();
    quest::exp(10000);
   }
}