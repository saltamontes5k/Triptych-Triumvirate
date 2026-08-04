#ifndef EQEMU_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H
#define EQEMU_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H

#pragma once

#include "../database.h"
#include "../strings.h"
#include "base/base_nms_waypoints_categories_repository.h"
#include "base/base_nms_waypoints_repository.h"
#include "base/base_nms_waypoints_default_repository.h"
#include "base/base_nms_waypoints_account_repository.h"
#include "base/base_nms_waypoints_character_repository.h"

#include "nms_waypoints_repository.h"
#include "nms_waypoints_categories_repository.h"
#include "nms_waypoints_character_repository.h"
#include "nms_waypoints_account_repository.h"

class NmsWaypointsDefaultRepository: public BaseNmsWaypointsDefaultRepository {
public:

    // Get all waypoint IDs for a character based on race, class, and level
    static std::vector<int32> GetWaypointIdsForCharacter(Database& db, int32 race_id, int32 class_id, int32 level) {
        std::vector<int32> waypoint_ids;

        // Class bitmask for the character's class (1 << (class_id - 1))
        uint32 class_bit = 1 << (class_id - 1);

        // Get waypoints where:
        // 1. Race matches OR race is 0 (any race) AND
        // 2. Class bitmask has the character's class bit set OR class_mask is 65535 (all classes) AND
        // 3. Level is between min_level and max_level
        auto results = db.QueryDatabase(
            fmt::format(
                "SELECT DISTINCT waypoint_id FROM {} "
                "WHERE (race_id = {} OR race_id = 0) "
                "AND ((class_mask & {}) > 0 OR class_mask = 65535) "
                "AND {} BETWEEN min_level AND max_level "
                "ORDER BY waypoint_id",
                TableName(),
                race_id,
                class_bit,
                level
            )
        );

        if (results.Success()) {
            for (auto row = results.begin(); row != results.end(); ++row) {
                waypoint_ids.push_back(Strings::ToInt(row[0]));
            }
        }

        return waypoint_ids;
    }
};

#endif //EQEMU_NMS_WAYPOINTS_DEFAULT_REPOSITORY_H