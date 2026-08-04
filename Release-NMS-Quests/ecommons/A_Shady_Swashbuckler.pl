sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $name, thanks for stopping by my shop.  Perhaps you'd be interested in something ...rare?");
	}
}
#::		my $accountID = 0;
#::			my $karma = 0;

#::			#:: Key a data bucket
#::			$key = $client->AccountID() . "-karma";

#::			#:: Match if key does not exist
#::			if (!quest::get_data($key)) {
#::				$accountID = $client->AccountID();
#::				$connect = plugin::LoadMysql();
#::				my $query_karma = "SELECT karma FROM account WHERE id = '$accountID';";
#::				$karma_query_handle = $connect->prepare($query_karma);
#::				$karma_query_handle->execute();
			
#::				while (@account_row = $karma_query_handle->fetchrow_array()) {
#::					$karma = $account_row[0];
#::				}

#::				quest::set_data($key, $karma);

#::				$client->SummonItem(103000, quest::get_data($key));
#::				$client->Message(15, "You have been awarded $karma Chronobines for your time in Norrath.");
#::			}
#::			else {
#::				$accountID = $client->AccountID();
#::				$connect = plugin::LoadMysql();
#::				my $query_karma = "SELECT karma FROM account WHERE id = $accountID;";
#::				$karma_query_handle = $connect->prepare($query_karma);
#::				$karma_query_handle->execute();
			
#::				while (@account_row = $karma_query_handle->fetchrow_array()) {
#::					$karma = $account_row[0];
#::				}

#::				my $total_karma_award = quest::get_data($key);
#::				my $award_currency = $karma - $total_karma_award;
				
#::				if ($award_currency == 0) {
#::					$client->Message(15, "Please check back later.  A Chronobine is earned every 20 minutes you are in Norrath.");
#::				}
#::				else {
#::					quest::set_data($key, $karma);
#::					$client->SummonItem(103000, $award_currency);
#::					$client->Message(15, "You have been awarded $award_currency Chronobines for your time in Norrath.");
#::				}
#::			}
#::		}
#::  }
