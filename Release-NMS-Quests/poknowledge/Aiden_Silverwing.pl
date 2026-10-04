# Aiden Silverwing - Plane of Knowledge (outside the Guild Lobby).
# Quest giver for the "Lost Heirlooms" / Silverwing Charm quest.
# items: 17335, 79621, 79623, 79627, 79631, 79635, 79639, 79643, 79647, 79651, 81110, 81111, 81112, 81113, 81114, 81115, 81116, 81117, 81118
#
# Hailing him hands out the Silverwing Lockbox (17335) if the player is not
# already carrying one. The nine tier combines are performed inside the lockbox
# and resolved by poknowledge/player.pl (EVENT_COMBINE_SUCCESS), which grants
# the class-appropriate result. The two final combines are ordinary recipes.

sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::say("Greetings, $race. I'm sorry, but I doubt I'll be much good company today. My entire [family] has fallen while exploring the wilds of Norrath, and I am the last of the Silverwings.");
		if (!plugin::check_hasitem($client, 17335)) {
			quest::say("Take this lockbox. The trinkets I made for my children were scattered across Norrath, and each shard of the metal I found can lend them its power.");
			quest::summonitem(17335); # Item: Silverwing Lockbox
		}
	}
	elsif ($text =~ /family/i) {
		quest::say("My children set off to the ends of Norrath to investigate a rather unique [metal] I found some time ago. Now they're all dead, and it's my fault for trying to keep this such a [secret].");
	}
	elsif ($text =~ /metal/i) {
		quest::say("Yes, a most wondrous metal it is too. It seems it can absorb magical energy, and take on a form of the properties of the energy, though I don't really understand how it all works yet.");
	}
	elsif ($text =~ /secret/i) {
		quest::say("I didn't want anyone else to know about it, so I had it made into trinkets. Simple [objects] really so they would go unnoticed, and gave one to each of my family members.");
	}
	elsif ($text =~ /objects/i) {
		quest::say("I know they won't bring my family back, but these trinkets are really all I have left of them. If you could [return] them to me I would be grateful beyond words.");
	}
	elsif ($text =~ /return/i) {
		quest::say("Veeshan be praised! I can't thank you enough, $name. Place a shard and the trinket it matches into the lockbox and combine them, and the metal will take on the shard's power. Bring the finished heirlooms together and I will see you rewarded.");
	}
}
