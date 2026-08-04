# BeginFile: abysmal\Magus_Pellen.pl
# NPCID 279217

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("I can provide you with travel to [Natimbi] and [Nedaria]'s Landing with our Farstone magic. Just tell me where you'd like to go and I shall send you.");
  } 
  elsif ($text=~/natimbi/i && plugin::is_eligible_for_zone($client, 'natimbi', 1)) {
    $client->MovePC(280, -1557, -853, 241, 180); # Zone: natimbi
  } 
  elsif ($text=~/nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
    $client->CastSpell(4580, $client->GetID(), 0, 1); # Spell: Teleport: Nedaria
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# EndFile: abysmal\Magus_Pellen.pl
