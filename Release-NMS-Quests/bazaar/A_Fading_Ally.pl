my $global_bucket_key 	= "froglok-unlock";
my $panic_npctype = 1120001110;

sub get_unlock_progress {
    if ($zoneid == 26) {
        return 501;
    } else {
        return quest::get_data($global_bucket_key);
    }
}

sub set_unlock_progress {
    my $unlock_progress = shift;
    if ($zoneid != 26) {
       quest::set_data($global_bucket_key, $unlock_progress);
    } 
}
	
sub EVENT_SAY {
	my $unlock_progress = get_unlock_progress();
	my $charname 		= $client->GetCleanName();
	my $response;

	if($text=~/Hail/i){				
		if($unlock_progress < 50) { #50
			$response = "$charname... That name sounds familiar. Do you remember me? I feel like I’ve forgotten something... or been forgotten?";
		} elsif($unlock_progress >= 50 && $unlock_progress < 100) {
			$response = "$charname! Yes! Yes, I believe we adventured together ages ago... or was that another adventurer? Was I an adventurer? Were we once heroes?";
		} elsif($unlock_progress >= 100 && $unlock_progress < 300) {
			$response = "$charname! I am starting to remember. The Rathe Mountains... my Guktan brothers and sisters. Our memories, you and I, are returning. Please, don’t stop now. I can feel something great swirling in the sea of time.";
		} elsif($unlock_progress >= 300 && $unlock_progress < 500) {
			$response = "$charname! I can see them now! I knew they were real! My people... Our existence must not be relegated to the sands of time. Soon... I will see them again soon! Still... ";
		} elsif($unlock_progress >= 500) {
			$response = "$charname! Oh no... no no no. I was wrong... I was so wrong. We didn't forget. We were too afraid to remember. Why did He abandon us? When Fear came calling... when we needed Him the most... He was nowhere to be found. [Panic] descended across the realms. But, why? He was our savior. He lead us from the shadows. He loved us and we worshipped Him for it. He wouldn't have just left us. You may have forgotten but He would never... not unless someone or some... thing... made him forget. Please. Please! You must remind Him. Remind Him of what only Fear now knows... Remind Him of what only Fear has seen... Remind Him of the Words used to completely erase us... Remind Him with the very blood that covers the hands of so many. ";
		}
		
		if ($unlock_progress < 500) {
			$response .= " My memories feel [scattered]. I wish I could remember.";
		}
	} elsif($text =~/scattered/i){
		$response = "It feels like the very memories that make me real have been scattered throughout places [we] once traveled... If you find them, please return them.";
	} elsif($text =~/we/i) {
		$response = "I feel so alone here... I wasn’t always alone. I had friends... and family... didn’t I?. The green orbs, maybe they hold an answer?";
	} elsif($text =~/Panic/i) {
        $response = "";
    }
	
	quest::say($response);
}

sub EVENT_ITEM { 
	my $copper = plugin::val('copper');
	my $silver = plugin::val('silver');
	my $gold = plugin::val('gold');
	my $platinum = plugin::val('platinum');
	my $total_money = ($platinum * 1000) + ($gold * 100) + ($silver * 10) + $copper;
	
	my $unlock_progress = get_unlock_progress();
	my $charname 		= $client->GetCleanName();
	my $count 			= 0;
	my $response;
	my $announce;

	foreach my $item_id (keys %itemcount) {
		if ($item_id == 976011) { #A Fading Green Memory
			if (($zoneid == 72 || $zoneid == 26) || $unlock_progress < 500) {
				$unlock_progress += $itemcount{$item_id};
				$count += $itemcount{$item_id};
				delete $itemcount{$item_id};
			
			} elsif (!$client->GetBucket("guktan-mask-obtained")) {
				$client->SetBucket("guktan-mask-obtained", 1);
				$client->SummonFixedItem(2054884);
				delete $itemcount{$item_id};
				quest::emote("The memory of a guktan conjures a ghostly mask.");	
			}		
		} else {
			quest::emote("The memory of a guktan stares into the distance, ignoring your presence.");			
		}
	}
	
	# After processing all items, return any remaining money
	my $platinum_remainder = int($total_money / 1000);
	$total_money %= 1000;

	my $gold_remainder = int($total_money / 100);
	$total_money %= 100;

	my $silver_remainder = int($total_money / 10);
	$total_money %= 10;

	my $copper_remainder = $total_money;

	$client->AddMoneyToPP($copper_remainder, $silver_remainder, $gold_remainder, $platinum_remainder, 1);
	#Return any unwanted items
	plugin::return_items(\%itemcount);
	
	set_unlock_progress($unlock_progress);
	
	if ($count) {
		
		my $account_key 	= $client->AccountID() . "froglok-memories-contributed";
		my $account_contrib = quest::get_data($account_key) + $count;

		quest::set_data($account_key, $account_contrib);
		
		$response = "Thanks be to $charname! Another memory dances free in our mind. ";
		if ($unlock_progress < 50) {
		} elsif ($unlock_progress >= 50 && $unlock_progress <= 100) {
			$response .= " Only a small number of memories have been brought to me so far, please help me! ";
		} elsif ($unlock_progress > 100 && $unlock_progress <= 300) {
			$response .= " The number of memories that have been collected grows... ";
		} elsif ($unlock_progress > 300 && $unlock_progress <= 500) {
			$response .= " Almost all of my memories have been collected. It cannot be long now... ";
		} elsif ($unlock_progress > 500 && ($zoneid == 72 || $zoneid == 26)) {
			if (!$entity_list->IsMobSpawnedByNpcTypeID($panic_npctype)) {
				$response .= " Oh Gods. I remember now! Something unspeakable comes for us!";
				quest::spawn2($panic_npctype, 0, 0, 352, 803, 205, 385);
			} else {
				$response .= " The Panic can only harm us if we fall prey to it!";
				my $panic_id = $entity_list->GetNPCByNPCTypeID($panic_npctype);
				if ($panic_id && $panic_id->GetTarget()) {
					$panic_id->SetHP($panic_id->GetHP() - ($panic_id->GetMaxHP() / 20));
					$panic_id->Shout("Who's memories are these?! I WILL NOT BE DENIED!");
				}
			}
		}

		quest::say($response);
	}
}