#ifndef EQEMU_ACCOUNT_ALT_CURRENCY_REPOSITORY_H
#define EQEMU_ACCOUNT_ALT_CURRENCY_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_account_alt_currency_repository.h"

class AccountAltCurrencyRepository: public BaseAccountAltCurrencyRepository {
public:

	static AccountAltCurrency FindByAccountAndCurrency(
		Database& db,
		int account_id,
		int currency_id
	) {
		auto results = GetWhere(
			db,
			fmt::format("account_id = {} AND currency_id = {}", account_id, currency_id)
		);

		return results.empty() ? NewEntity() : results[0];
	}

	static int UpdateByAccountAndCurrency(
		Database& db,
		int account_id,
		int currency_id,
		uint32_t amount
	) {
		AccountAltCurrency e{};
		e.account_id = account_id;
		e.currency_id = currency_id;
		e.amount = amount;

		return ReplaceOne(db, e);
	}

};

#endif //EQEMU_ACCOUNT_ALT_CURRENCY_REPOSITORY_H
