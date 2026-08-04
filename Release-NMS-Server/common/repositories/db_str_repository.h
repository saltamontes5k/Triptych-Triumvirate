#ifndef EQEMU_DB_STR_REPOSITORY_H
#define EQEMU_DB_STR_REPOSITORY_H

#include "../database.h"
#include "../strings.h"
#include "base/base_db_str_repository.h"

class DbStrRepository: public BaseDbStrRepository {
public:

    /**
     * This file was auto generated and can be modified and extended upon
     *
     * Base repository methods are automatically
     * generated in the "base" version of this repository. The base repository
     * is immutable and to be left untouched, while methods in this class
     * are used as extension methods for more specific persistence-layer
     * accessors or mutators.
     *
     * Base Methods (Subject to be expanded upon in time)
     *
     * Note: Not all tables are designed appropriately to fit functionality with all base methods
     *
     * InsertOne
     * UpdateOne
     * DeleteOne
     * FindOne
     * GetWhere(std::string where_filter)
     * DeleteWhere(std::string where_filter)
     * InsertMany
     * All
     *
     * Example custom methods in a repository
     *
     * DbStrRepository::GetByZoneAndVersion(int zone_id, int zone_version)
     * DbStrRepository::GetWhereNeverExpires()
     * DbStrRepository::GetWhereXAndY()
     * DbStrRepository::DeleteWhereXAndY()
     *
     * Most of the above could be covered by base methods, but if you as a developer
     * find yourself re-using logic for other parts of the code, its best to just make a
     * method that can be re-used easily elsewhere especially if it can use a base repository
     * method and encapsulate filters there
     */

	// Custom extended repository methods here
	static std::vector<std::string> GetDBStrFileLines(Database& db)
	{
		std::vector<std::string> lines;

		auto results = db.QueryDatabase(
			fmt::format(
				"SELECT CONCAT(CONCAT_WS('^', {}), '^0') FROM {} ORDER BY `id`, `type` ASC",
				ColumnsRaw(),
				TableName()
			)
		);



		for (auto row : results) {
			lines.emplace_back(row[0]);
		}

		return lines;
	}

	static std::vector<std::string> GetDBStrFileLinesMulticlass(Database& db, Database& content_db)
	{
	std::vector<std::string> lines;

	// Class bitmask to class name map
	const std::vector<std::pair<int, std::string>> class_map = {
		{1, "WAR"}, {2, "CLR"}, {4, "PAL"}, {8, "RNG"}, {16, "SHD"}, {32, "DRU"},
		{64, "MNK"}, {128, "BRD"}, {256, "ROG"}, {512, "SHM"}, {1024, "NEC"},
		{2048, "WIZ"}, {4096, "MAG"}, {8192, "ENC"}, {16384, "BST"}, {32768, "BER"}
	};

	// Query the base table
	auto results = db.QueryDatabase(
		fmt::format(
			"SELECT CONCAT(CONCAT_WS('^', {}), '^0') FROM {} ORDER BY `id`, `type` ASC",
			ColumnsRaw(),
			TableName()
		)
	);

	// Preload all desc_sid -> aa_ability.classes
	std::unordered_map<std::string, int> descsid_to_classes;
	auto class_results = content_db.QueryDatabase(
		"SELECT aa_ranks.desc_sid, aa_ability.classes FROM aa_ability "
		"JOIN aa_ranks ON aa_ability.first_rank_id = aa_ranks.id "
		"WHERE aa_ranks.level_req <= 70"
	);
	for (auto row : class_results) {
		descsid_to_classes[row[0]] = Strings::ToInt(row[1]);
	}

	// Preload all desc_sid -> activation info
	struct ActivationInfo {
		int recast_time;
		int spell_id;
		int ability_id;
	};
	std::unordered_map<std::string, ActivationInfo> descsid_to_activation;
	auto activation_results = content_db.QueryDatabase(
		"SELECT aa_ranks.desc_sid, aa_ranks.recast_time, aa_ranks.spell, aa_ability.id FROM aa_ability "
		"JOIN aa_ranks ON aa_ability.first_rank_id = aa_ranks.id "
		"WHERE aa_ranks.level_req <= 70"
	);
	for (auto row : activation_results) {
		descsid_to_activation[row[0]] = {
			Strings::ToInt(row[1]),
			Strings::ToInt(row[2]),
			Strings::ToInt(row[3])
		};
	}

	// Process each line from the base query
	for (auto row : results) {
		std::string line = row[0];
		std::stringstream ss(line);
		std::string item;
		std::vector<std::string> columns;

		while (std::getline(ss, item, '^')) {
			columns.push_back(item);
		}

		if (columns.size() > 2 && columns[1] == "4") {
			const std::string& desc_sid = columns[0];

			auto class_it = descsid_to_classes.find(desc_sid);
			auto act_it = descsid_to_activation.find(desc_sid);

			if (class_it != descsid_to_classes.end()) {
				int aa_classes = class_it->second;

				std::string activation_info;
				if (act_it != descsid_to_activation.end()) {
					const auto& act = act_it->second;
					if (act.recast_time > 0 && act.spell_id > -1) {
						activation_info = " [/alt activate " + std::to_string(act.ability_id) + "]";
					} else {
						activation_info = " [/alt toggle " + std::to_string(act.ability_id) + "]";
					}
				}

				if (aa_classes != 65535) {
					std::vector<std::string> class_tags;
					for (const auto& [bit, name] : class_map) {
						if (aa_classes & bit)
							class_tags.push_back(name);
					}
					std::string tag = "(" + Strings::Join(class_tags, " ") + ")" + activation_info;
					columns[2] = tag + "<br>" + columns[2];
				} else {
					columns[2] = "(ALL)" + activation_info + "<br>" + columns[2];
				}
			}
		}

		std::string modified_line;
		for (size_t i = 0; i < columns.size(); ++i) {
			if (i > 0) modified_line += '^';
			modified_line += columns[i];
		}
		lines.emplace_back(modified_line);
	}

	return lines;
	}

};

#endif //EQEMU_DB_STR_REPOSITORY_H
