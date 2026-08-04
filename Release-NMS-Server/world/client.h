/*	EQ Everquest Server Emulator
	Copyright (C) 2001-2002 EQ:: Development Team (http://EQ::.org)

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
#ifndef CLIENT_H
#define CLIENT_H

#include <string>

#include "../common/linked_list.h"
#include "../common/timer.h"
#include "../common/inventory_profile.h"
//#include "zoneserver.h"

#include "../common/eq_packet_structs.h"
#include "cliententry.h"

#include "../common/repositories/account_character_sets_repository.h"
#include "../common/repositories/account_character_set_limits_repository.h"
#include "../common/repositories/account_character_set_members_repository.h"
#include "../common/repositories/character_data_repository.h"

class EQApplicationPacket;
class EQStreamInterface;

constexpr uint8 MAX_CHARACTER_SETS = 64;
constexpr uint8 EOM_CURRENCY_ID = 6;

class Client {
public:
	Client(EQStreamInterface* ieqs);
	~Client();

	bool	Process();
	void	SendCharInfo(uint32 character_set = 0);
	void	SendMaxCharCreate();
	void	SendMembership();
	void	SendMembershipSettings();
	void	EnterWorld(bool TryBootup = true);
	void	TellClientZoneUnavailable();
	void	QueuePacket(const EQApplicationPacket* app, bool ack_req = true);
	void	Clearance(int8 response);
	void	SendGuildList();
	void	SendEnterWorld(std::string name);
	void	SendExpansionInfo();
	void	SendLogServer();
	void	SendApproveWorld();
	void	SendPostEnterWorld();
	void    SendGuildTributeFavorAndTimer(uint32 favor, uint32 time_remaining);
	void    SendGuildTributeOptInToggle(const GuildTributeMemberToggle* in);

	inline uint32		GetIP()				{ return ip; }
	inline uint16		GetPort()			{ return port; }
	inline uint32		GetZoneID()			{ return zone_id; }
	inline uint32		GetInstanceID()		{ return instance_id; }
	inline uint32		WaitingForBootup()	{ return zone_waiting_for_bootup; }
	inline const char *	GetAccountName()	{ if (cle) { return cle->AccountName(); } return "NOCLE"; }
	inline int16		GetAdmin()			{ if (cle) { return cle->Admin(); } return 0; }
	inline uint32		GetAccountID()		{ if (cle) { return cle->AccountID(); } return 0; }
	inline uint32		GetWID()			{ if (cle) { return cle->GetID(); } return 0; }
	inline uint32		GetLSID()			{ if (cle) { return cle->LSID(); } return 0; }
	inline const char*	GetLSKey()			{ if (cle) { return cle->GetLSKey(); } return "NOKEY"; }
	inline uint32		GetCharID()			{ return charid; }
	inline const char*	GetCharName()		{ return char_name; }
	inline EQ::versions::ClientVersion	GetClientVersion()	{ return m_ClientVersion; }
	inline ClientListEntry* GetCLE()		{ return cle; }
	inline void			SetCLE(ClientListEntry* iCLE)			{ cle = iCLE; }
	bool StoreCharacter(
		uint32 account_id,
		PlayerProfile_Struct *p_player_profile_struct,
		EQ::InventoryProfile *p_inventory_profile
	);

	void SendCharacterSetInfo();
	void PopulateCharacterDataCache();
	void WritebackCharacterDataCache();
	std::vector<uint32> GetCharacterIDsForSetFromCache(uint32 set_id);
	bool AddCharacterToSetInCache(uint32 set_id, uint32 character_id);
	std::vector<CharacterDataRepository::CharacterData> GetCharactersForSetFromCache(uint32 set_id);
	AccountCharacterSetsRepository::AccountCharacterSets CreateCharacterSetInCache(const std::string& set_name);
	bool DeleteCharacterSet(uint32 set_id);
	bool RenameCharacterSetInCache(uint32 set_id, const std::string& new_name);
	void RemoveCharacterFromSetInCache(uint32 character_id, uint32 set_id);
	uint8 GetMaxCharacterSets();
	bool CanCreateMoreCharacterSets();
	uint32 GetMaxCharacterSlots();
	uint32 GetAvailableSlotUnlocks();
	uint32 GetAvailableSetUnlocks();
	bool CanCreateNewCharacter();
	bool GrantBonusCharacterSets(uint32 quantity);
	bool GrantBonusCharacterSlots(uint32 quantity);
	void UpdateSelectedCharacterSet(uint32 set_id);
	bool DeleteCharacterByNameFromCache(const std::string& character_name);

	enum CharacterSetUnlockAction {
		CHARACTER_SLOT = 1,
		CHARACTER_SET  = 0
	};

private:

	uint32	ip;
	uint16	port;
	uint32	charid;
	char	char_name[64];
	uint32	zone_id;
	uint32	instance_id;
	bool	is_player_zoning;
	Timer	autobootup_timeout;
	uint32	zone_waiting_for_bootup;
	bool	enter_world_triggered;

	uint32  m_selected_character_set;
	uint32  m_default_character_set;
	uint32  m_eom_available;

	AccountCharacterSetLimitsRepository::AccountCharacterSetLimits m_character_set_meta;
	std::vector<AccountCharacterSetsRepository::AccountCharacterSets> m_character_sets;
	std::vector<AccountCharacterSetMembersRepository::AccountCharacterSetMembers> m_character_set_members;
	std::vector<CharacterDataRepository::CharacterData> m_account_characters;

	bool StartInTutorial;
	EQ::versions::ClientVersion m_ClientVersion;
	uint32 m_ClientVersionBit;
	bool OPCharCreate(char *name, CharCreate_Struct *cc);

	void SetClassStartingSkills( PlayerProfile_Struct *pp );
	void SetRaceStartingSkills( PlayerProfile_Struct *pp );
	void SetRacialLanguages( PlayerProfile_Struct *pp );
	void SetClassLanguages(PlayerProfile_Struct *pp);

	ClientListEntry* cle;
	Timer	connect;
	bool seen_character_select;

	bool HandlePacket(const EQApplicationPacket *app);
	bool HandleNameApprovalPacket(const EQApplicationPacket *app);
	bool HandleSendLoginInfoPacket(const EQApplicationPacket *app);
	bool HandleGenerateRandomNamePacket(const EQApplicationPacket *app);
	bool HandleCharacterCreateRequestPacket(const EQApplicationPacket *app);
	bool HandleCharacterCreatePacket(const EQApplicationPacket *app);
	bool HandleEnterWorldPacket(const EQApplicationPacket *app);
	bool HandleDeleteCharacterPacket(const EQApplicationPacket *app);
	bool HandleZoneChangePacket(const EQApplicationPacket *app);
	bool HandleChecksumPacket(const EQApplicationPacket *app);
	bool HandleCharacterSetRequest(const EQApplicationPacket *app);
	bool HandleCharacterSetCreateRequest(const EQApplicationPacket *app);
	bool HandleCharacterSetMoveRequest(const EQApplicationPacket *app);
	bool HandleCharacterSetUnlockRequest(const EQApplicationPacket *app);
	bool ChecksumVerificationCRCEQGame(uint64 checksum);
	bool ChecksumVerificationCRCSkillCaps(uint64 checksum);
	bool ChecksumVerificationCRCBaseData(uint64 checksum);

	bool HandleSetUnlock(uint32 quantity);
	bool HandleSlotUnlock(uint32 quantity);

	EQStreamInterface* eqs;
	bool CanTradeFVNoDropItem();
	void RecordPossibleHack(const std::string& message);
	void SendUnsupportedClientPacket(const std::string& message);

	void LoadDataBucketsCache();
	void ClearDataBucketsCache();
};

bool CheckCharCreateInfoSoF(CharCreate_Struct *cc);
bool CheckCharCreateInfoTitanium(CharCreate_Struct *cc);

#endif
