/*	EQEMu: Everquest Server Emulator
	Copyright (C) 2001-2015 EQEMu Development Team (http://eqemulator.net)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include "../common/global_define.h"
#include "../common/types.h"
#include "masterentity.h"
#include "aa_ability.h"

AA::Rank *AA::Ability::GetRankByPointsSpent(int current_level) {
	if(current_level == 0)
		return nullptr;

	if(!first)
		return nullptr;

	int i = 1;
	Rank *current = first;
	while(current->next) {
		if(i == current_level) {
			break;
		}

		i++;
		current = current->next;
	}

	return current;
}

int AA::Ability::GetMaxLevel(Mob *who) {
	int max_level = 0;
	Rank *current = first;
	while(current) {
		if(!who->CanUseAlternateAdvancementRank(current)) {
			return max_level;
		}

		max_level++;
		current = current->next;
	}

	return max_level;
}

// NMS: total effect magnitude across every rank the player can use. Used to
// pick the single best line when multiple abilities share a name (duplicates).
// Each effect contributes the larger magnitude of base1/base2 so SPAs that carry
// their value in base2 (e.g. crit damage) are scored correctly.
int64 AA::Ability::GetLineStrength(Mob *who) {
	int64 strength = 0;

	Rank *current = first;
	while (current) {
		if (!who->CanUseAlternateAdvancementRank(current)) {
			break;
		}

		for (const auto &e : current->effects) {
			int64 b1 = e.base_value < 0 ? -static_cast<int64>(e.base_value) : static_cast<int64>(e.base_value);
			int64 b2 = e.limit_value < 0 ? -static_cast<int64>(e.limit_value) : static_cast<int64>(e.limit_value);
			strength += (b1 > b2 ? b1 : b2);
		}

		current = current->next;
	}

	return strength;
}

int AA::Ability::GetMaxExpansion(Mob *who) {
	int max_expansion = 0;

	Rank *current = first;
	while (current) {
		if (!who->CanUseAlternateAdvancementRank(current)) {
			break;
		}

		if (current->expansion > max_expansion) {
			max_expansion = current->expansion;
		}

		current = current->next;
	}

	return max_expansion;
}
