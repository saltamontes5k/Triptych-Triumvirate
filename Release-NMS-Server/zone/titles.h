#ifndef TITLES_H
#define TITLES_H

#include <unordered_map>
#include <vector>
#include "../common/repositories/titles_repository.h"

class Client;
class EQApplicationPacket;

class TitleManager
{
public:
	TitleManager();

	bool LoadTitles();

	EQApplicationPacket* MakeTitlesPacket(Client* c);
	std::string GetPrefix(int title_id);
	std::string GetSuffix(int title_id);
	std::vector<TitlesRepository::Titles> GetEligibleTitles(Client* c);
	bool IsNewAATitleAvailable(int aa_points, int class_id);
	bool IsNewTradeSkillTitleAvailable(int t, int skill_value);
	void CreateNewPlayerTitle(Client* c, std::string title);
	void CreateNewPlayerSuffix(Client* c, std::string suffix);
	bool HasTitle(Client* c, uint32 title_id);
	void CheckAndGrantTitle(Client* c, uint32 item_id);
	inline const std::vector<TitlesRepository::Titles>& GetTitles() { return titles; }

protected:
	std::vector<TitlesRepository::Titles> titles;

	// Item-gated (epic) title caches, keyed by title_set and by item id.
	// Recognized item ids cover every tier/family form of an epic item
	// (base, Enchanted, Legendary, alternate families, the warrior pair).
	std::unordered_map<uint32_t, std::vector<uint32_t>> epic_item_ids_by_title_set;
	std::unordered_map<uint32_t, uint32_t> epic_title_set_by_item_id;

	void LoadEpicItemCache();
};

extern TitleManager title_manager;

#endif

