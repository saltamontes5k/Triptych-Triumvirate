sub EVENT_SPELL_EFFECT_CLIENT
{
	quest::summonfixeditem(2028034);
	$client->RemoveItem(28034);
}