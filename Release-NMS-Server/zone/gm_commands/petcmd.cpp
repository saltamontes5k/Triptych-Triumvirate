#include "../client.h"
#include <sstream>

// Forward declarations
struct PetToggleCommand {
    int base;
    int on;
    int off;
};

// Token-based pet command parser and executor
class PetCommandParser {
public:
    struct ParsedCommand {
        std::vector<int> command_codes;
        std::vector<uint8> class_targets;
        bool target_all_classes = false;
        bool target_swarm = false;
    };

    // Public access to static data for use by other classes
    static const std::map<std::string, int> simple_commands;
    static const std::map<std::string, PetToggleCommand> toggle_commands;
    static const std::map<std::string, uint8> class_mappings;
    static const std::set<int> swarm_unsupported_commands;

private:
    // Convert command string to tokens, avoiding C-string manipulation
    static std::vector<std::string> tokenize(const std::string& input) {
        std::vector<std::string> tokens;
        std::istringstream stream(input);
        std::string token;

        while (stream >> token) {
            tokens.push_back(Strings::ToLower(token));
        }

        return tokens;
    }

    // Parse multi-word commands and consolidate tokens
    static std::vector<std::string> consolidateMultiWordCommands(const std::vector<std::string>& tokens) {
        const std::map<std::pair<std::string, std::string>, std::string> multi_word_map = {
            {{"follow", "me"}, "followme"},
            {{"guard", "here"}, "guardhere"},
            {{"get", "lost"}, "getlost"},
            {{"assist", "me"}, "assistme"},
            {{"back", "off"}, "backoff"},
            {{"health", "report"}, "healthreport"},
            {{"play", "dead"}, "feign"}
        };

        std::vector<std::string> consolidated;

        for (size_t i = 0; i < tokens.size(); ++i) {
            bool found_multi_word = false;

            // Check for multi-word commands
            if (i + 1 < tokens.size()) {
                auto pair = std::make_pair(tokens[i], tokens[i + 1]);
                auto it = multi_word_map.find(pair);
                if (it != multi_word_map.end()) {
                    consolidated.push_back(it->second);
                    ++i; // Skip the next token since we consumed it
                    found_multi_word = true;
                }
            }

            if (!found_multi_word) {
                consolidated.push_back(tokens[i]);
            }
        }

        return consolidated;
    }

    // Parse targets from token list
    static void parseTargets(const std::vector<std::string>& tokens, ParsedCommand& result) {
        for (const auto& token : tokens) {
            if (token == "all") {
                result.target_all_classes = true;
            } else if (token == "swarm") {
                result.target_swarm = true;
            } else {
                auto class_it = class_mappings.find(token);
                if (class_it != class_mappings.end()) {
                    result.class_targets.push_back(class_it->second);
                }
            }
        }

        // Default behavior: if no targets specified, target all classes (but not swarm)
        if (!result.target_all_classes && !result.target_swarm && result.class_targets.empty()) {
            result.target_all_classes = true;
        }
    }

    // Parse commands from token list
    static bool parseCommands(const std::vector<std::string>& tokens, ParsedCommand& result) {
        for (size_t i = 0; i < tokens.size(); ++i) {
            const std::string& token = tokens[i];

            // Skip target tokens
            if (token == "all" || token == "swarm" || class_mappings.count(token)) {
                continue;
            }

            // Check simple commands
            auto simple_it = simple_commands.find(token);
            if (simple_it != simple_commands.end()) {
                result.command_codes.push_back(simple_it->second);
                continue;
            }

            // Check toggle commands
            auto toggle_it = toggle_commands.find(token);
            if (toggle_it != toggle_commands.end()) {
                int cmd_code = toggle_it->second.base;

                // Check for on/off modifier
                if (i + 1 < tokens.size()) {
                    const std::string& next_token = tokens[i + 1];
                    if (next_token == "on") {
                        cmd_code = toggle_it->second.on;
                        ++i; // Skip the "on" token
                    } else if (next_token == "off") {
                        cmd_code = toggle_it->second.off;
                        ++i; // Skip the "off" token
                    }
                }

                result.command_codes.push_back(cmd_code);
                continue;
            }
        }

        return !result.command_codes.empty();
    }

public:
    static ParsedCommand parse(const std::string& command_string) {
        ParsedCommand result;

        // Step 1: Tokenize input
        auto tokens = tokenize(command_string);
        if (tokens.empty()) {
            return result;
        }

        // Step 2: Consolidate multi-word commands
        auto consolidated_tokens = consolidateMultiWordCommands(tokens);

        // Step 3: Parse targets
        parseTargets(consolidated_tokens, result);

        // Step 4: Parse commands
        parseCommands(consolidated_tokens, result);

        return result;
    }
};

// Pet command execution helper
class PetCommandExecutor {
private:
    static std::string getCommandName(int cmd) {
        static const std::map<int, std::string> cmd_names = {
            {PET_FOLLOWME, "follow"}, {PET_GUARDHERE, "guard"}, {PET_SIT, "sit"},
            {PET_HEALTHREPORT, "health"}, {PET_FEIGN, "feign"},
            {PET_REGROUP, "regroup"}, {PET_REGROUP_ON, "regroup"}, {PET_REGROUP_OFF, "regroup"},
            {PET_SPELLHOLD, "spellhold"}, {PET_SPELLHOLD_ON, "spellhold"}, {PET_SPELLHOLD_OFF, "spellhold"},
            {PET_TAUNT, "taunt"}, {PET_TAUNT_ON, "taunt"}, {PET_TAUNT_OFF, "taunt"}
        };

        auto it = cmd_names.find(cmd);
        return (it != cmd_names.end()) ? it->second : "unknown";
    }

    static bool validateSwarmCommands(const std::vector<int>& commands, Client* c) {
        std::vector<std::string> unsupported;

        for (int cmd : commands) {
            if (PetCommandParser::swarm_unsupported_commands.count(cmd)) {
                unsupported.push_back(getCommandName(cmd));
            }
        }

        if (!unsupported.empty()) {
            std::string msg = "The following commands are not supported by swarm pets: " +
                             Strings::Join(unsupported, ", ");
            c->Message(Chat::PetResponse, msg.c_str());
            return false;
        }

        return true;
    }

    static void executeSwarmPersistentCommands(const std::vector<int>& commands, Client* c) {
        for (int cmd : commands) {
            switch (cmd) {
                case PET_HOLD:
                case PET_HOLD_ON:
                case PET_HOLD_OFF:
                    handleSwarmToggle(c, "hold", cmd, PET_HOLD, PET_HOLD_ON, PET_HOLD_OFF);
                    break;
                case PET_GHOLD:
                case PET_GHOLD_ON:
                case PET_GHOLD_OFF:
                    handleSwarmToggle(c, "ghold", cmd, PET_GHOLD, PET_GHOLD_ON, PET_GHOLD_OFF);
                    break;
                case PET_FOCUS:
                case PET_FOCUS_ON:
                case PET_FOCUS_OFF:
                    handleSwarmToggle(c, "focus", cmd, PET_FOCUS, PET_FOCUS_ON, PET_FOCUS_OFF);
                    break;
                case CUSTOM_PET_ASSIST:
                case CUSTOM_PET_ASSIST_ON:
                case CUSTOM_PET_ASSIST_OFF:
                    handleSwarmToggle(c, "assist", cmd, CUSTOM_PET_ASSIST, CUSTOM_PET_ASSIST_ON, CUSTOM_PET_ASSIST_OFF);
                    break;
            }
        }
    }

	static void handleSwarmToggle(Client* c, const std::string& setting_name, int cmd, int base, int on, int off) {
		if (!c || setting_name.empty()) {
			LogErrorDetail("Failed to parse swarm pet command.");
			return;
		}

		bool cur_value = c->GetSavedPetCommand(Class::None, base);

		if (cmd == base) {
			std::string new_setting = cur_value ? "on" : "off";
			c->Message(Chat::PetResponse, fmt::format("Swarm pet {} setting: {}", setting_name, (new_setting == "on") ? "ON" : "OFF").c_str());
		} else if (cmd == on) {
			c->SetSavedPetCommand(Class::None, base, true);
			c->Message(Chat::PetResponse, fmt::format("Swarm pet {} setting: ON", setting_name).c_str());
		} else if (cmd == off) {
			c->SetSavedPetCommand(Class::None, base, false);
			c->Message(Chat::PetResponse, fmt::format("Swarm pet {} setting: OFF", setting_name).c_str());
		}
	}

public:
    static bool execute(const PetCommandParser::ParsedCommand& parsed_cmd, Client* c) {
        if (parsed_cmd.command_codes.empty()) {
            return false;
        }

        Mob* target = c->GetTarget();

        // Handle swarm pets
        if (parsed_cmd.target_swarm) {
            if (!validateSwarmCommands(parsed_cmd.command_codes, c)) {
                return false;
            }

            // Separate persistent and immediate commands
            std::vector<int> persistent_commands;
            std::vector<int> immediate_commands;

            for (int cmd : parsed_cmd.command_codes) {
                if (cmd == PET_HOLD || cmd == PET_HOLD_ON || cmd == PET_HOLD_OFF ||
                    cmd == PET_GHOLD || cmd == PET_GHOLD_ON || cmd == PET_GHOLD_OFF ||
                    cmd == PET_FOCUS || cmd == PET_FOCUS_ON || cmd == PET_FOCUS_OFF ||
                    cmd == CUSTOM_PET_ASSIST || cmd == CUSTOM_PET_ASSIST_ON || cmd == CUSTOM_PET_ASSIST_OFF) {
                    persistent_commands.push_back(cmd);
                } else {
                    immediate_commands.push_back(cmd);
                }
            }

            executeSwarmPersistentCommands(persistent_commands, c);

            if (!immediate_commands.empty()) {
                auto swarm_pets = c->GetAllSwarmPets();
                if (swarm_pets.empty()) {
                    c->Message(Chat::PetResponse, "You don't have any swarm pets under your control.");
                    return false;
                }

                for (auto swarm_pet : swarm_pets) {
                    if (swarm_pet && swarm_pet->IsNPC()) {
                        for (int cmd : immediate_commands) {
                            swarm_pet->CastToNPC()->DoPetCommand(cmd, target);
                        }
                    }
                }
            }
        }

        // Handle regular pets
        if (parsed_cmd.target_all_classes || !parsed_cmd.class_targets.empty()) {
            auto pets = c->GetAllPets();
            if (pets.empty()) {
                c->Message(Chat::PetResponse, "You don't have any pets under your control.");
                return false;
            }

            for (auto pet : pets) {
                if (!pet || !pet->IsNPC()) {
                    continue;
                }

                auto pet_class_id = pet->CastToNPC()->GetPetOriginClass();

                if (parsed_cmd.target_all_classes ||
                    std::find(parsed_cmd.class_targets.begin(), parsed_cmd.class_targets.end(), pet_class_id) != parsed_cmd.class_targets.end()) {

                    for (int cmd : parsed_cmd.command_codes) {
                        pet->CastToNPC()->DoPetCommand(cmd, target);
                    }
                }
            }
        }

        return true;
    }
};

// Static member definitions - must come after class declarations
const std::map<std::string, int> PetCommandParser::simple_commands = {
    {"attack", PET_ATTACK},
    {"qattack", PET_QATTACK},
    {"follow", PET_FOLLOWME}, {"followme", PET_FOLLOWME},
    {"guard", PET_GUARDHERE}, {"guardhere", PET_GUARDHERE},
    {"sit", PET_SIT},
    {"stop", PET_STOP}, {"freeze", PET_STOP},
    {"back", PET_BACKOFF}, {"backoff", PET_BACKOFF},
    {"leave", PET_GETLOST}, {"dismiss", PET_GETLOST}, {"getlost", PET_GETLOST},
    {"health", PET_HEALTHREPORT}, {"healthreport", PET_HEALTHREPORT},
    {"hp", PET_HEALTHREPORT}, {"stats", PET_HEALTHREPORT},
    {"inventory", PET_HEALTHREPORT}, {"inv", PET_HEALTHREPORT},
    {"leader", PET_LEADER}, {"master", PET_LEADER},
    {"feign", PET_FEIGN}, {"fd", PET_FEIGN}, {"playdead", PET_FEIGN}
};

const std::map<std::string, PetToggleCommand> PetCommandParser::toggle_commands = {
    {"taunt", {PET_TAUNT, PET_TAUNT_ON, PET_TAUNT_OFF}},
    {"hold", {PET_HOLD, PET_HOLD_ON, PET_HOLD_OFF}},
    {"ghold", {PET_GHOLD, PET_GHOLD_ON, PET_GHOLD_OFF}},
    {"spellhold", {PET_SPELLHOLD, PET_SPELLHOLD_ON, PET_SPELLHOLD_OFF}},
    {"nocast", {PET_SPELLHOLD, PET_SPELLHOLD_ON, PET_SPELLHOLD_OFF}},
    {"focus", {PET_FOCUS, PET_FOCUS_ON, PET_FOCUS_OFF}},
    {"regroup", {PET_REGROUP, PET_REGROUP_ON, PET_REGROUP_OFF}},
    {"assist", {CUSTOM_PET_ASSIST, CUSTOM_PET_ASSIST_ON, CUSTOM_PET_ASSIST_OFF}},
    {"assistme", {CUSTOM_PET_ASSIST, CUSTOM_PET_ASSIST_ON, CUSTOM_PET_ASSIST_OFF}}
};

const std::map<std::string, uint8> PetCommandParser::class_mappings = {
    {"mag", Class::Magician}, {"mage", Class::Magician}, {"magician", Class::Magician},
    {"bst", Class::Beastlord}, {"bl", Class::Beastlord}, {"beast", Class::Beastlord}, {"beastlord", Class::Beastlord},
    {"nec", Class::Necromancer}, {"necro", Class::Necromancer}, {"necromancer", Class::Necromancer},
    {"enc", Class::Enchanter}, {"ench", Class::Enchanter}, {"enchanter", Class::Enchanter},
    {"shm", Class::Shaman}, {"shaman", Class::Shaman},
    {"dru", Class::Druid}, {"druid", Class::Druid},
    {"brd", Class::Bard}, {"bard", Class::Bard},
    {"shd", Class::ShadowKnight}, {"sk", Class::ShadowKnight}, {"shadowknight", Class::ShadowKnight},
    {"war", Class::Warrior}, {"warrior", Class::Warrior},
    {"clr", Class::Cleric}, {"cler", Class::Cleric}, {"cleric", Class::Cleric},
    {"pal", Class::Paladin}, {"paladin", Class::Paladin},
    {"rng", Class::Ranger}, {"ranger", Class::Ranger},
    {"mnk", Class::Monk}, {"monk", Class::Monk},
    {"rog", Class::Rogue}, {"rogue", Class::Rogue},
    {"wiz", Class::Wizard}, {"wizard", Class::Wizard},
    {"ber", Class::Berserker}, {"berserker", Class::Berserker}
};

const std::set<int> PetCommandParser::swarm_unsupported_commands = {
    PET_FOLLOWME, PET_GUARDHERE, PET_SIT, PET_HEALTHREPORT, PET_FEIGN,
    PET_REGROUP, PET_REGROUP_ON, PET_REGROUP_OFF,
    PET_SPELLHOLD, PET_SPELLHOLD_ON, PET_SPELLHOLD_OFF,
    PET_TAUNT, PET_TAUNT_ON, PET_TAUNT_OFF
};

// Main command handler function
void command_petcmd(Client *c, const Seperator *sep) {
    if (!c || !sep) {
        return;
    }

    const std::string usage = "Usage: #petcmd [attack, qattack, follow, guard, sit, stop, taunt (on\\off), hold (on\\off), ghold (on\\off), spellhold (on\\off), focus (on\\off), back, regroup (on\\off), assist (on\\off), health, leader, feign, leave] [all, swarm, mag, bst, nec, enc, shm, dru, brd, shd]. Verbs do not need to be applied in any specific order.";

    // Build command string from separator arguments
    std::string command_string;
    for (uint16 i = 0; i <= sep->argnum && i < sep->GetMaxArgNum(); ++i) {
        if (sep->arg[i] != nullptr) {
            if (!command_string.empty()) {
                command_string += " ";
            }
            command_string += sep->arg[i];
        }
    }

    if (command_string.empty()) {
        c->Message(Chat::PetResponse, usage.c_str());
        return;
    }

    // Parse and execute command
    auto parsed_command = PetCommandParser::parse(command_string);

    if (!PetCommandExecutor::execute(parsed_command, c)) {
        c->Message(Chat::PetResponse, usage.c_str());
    }
}