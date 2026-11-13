/*	EQEMu: Everquest Server Emulator
	
	Copyright (C) 2001-2016 EQEMu Development Team (http://eqemulator.net)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef COMMON_ROF2_H
#define COMMON_ROF2_H

#include "../struct_strategy.h"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <vector>

class EQStreamIdentifier;

namespace EQ { class ItemInstance; }

struct Spawn_Struct;
struct PlayerProfile_Struct;

namespace RoF2
{

	//these are the only public member of this namespace.
	extern void Register(EQStreamIdentifier &into);
	extern void Reload();

	// Native Spirit Shroud serializers (RoF2 May 2013 protocol): one-packet
	// captures of the ordinary struct strategy encoders.
	std::optional<std::vector<uint8_t>> SerializeShroudSpawn(const Spawn_Struct&);
	std::optional<std::vector<uint8_t>> SerializeShroudNormalProfile(const PlayerProfile_Struct&);
	std::optional<std::vector<uint8_t>> SerializeShroudInventory(const std::vector<std::pair<int16_t, const EQ::ItemInstance*>>&);
	// Shroud inspection cache entry: native ItemPtr without an ItemPacket type
	// or inventory count.
	std::optional<std::vector<uint8_t>> SerializeShroudPreviewItem(const EQ::ItemInstance &instance);
	// Fully encoded normal ItemPacketTrade for a prepared shroud-bank tree.
	std::optional<std::vector<uint8_t>> SerializeShroudBankItem(const EQ::ItemInstance&, int16_t server_slot);



	//you should not directly access anything below..
	//I just dont feel like making a seperate header for it.

	class Strategy : public StructStrategy {
	public:
		Strategy();

	protected:

		virtual std::string Describe() const;
		virtual const EQ::versions::ClientVersion ClientVersion() const;

		//magic macro to declare our opcode processors
		#include "ss_declare.h"
		#include "rof2_ops.h"
	};

}; /*RoF2*/

#endif /*COMMON_ROF2_H*/
