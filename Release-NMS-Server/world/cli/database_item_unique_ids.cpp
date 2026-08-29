#include "../world_server_cli.h"

#include "../worlddb.h"

#include <cstdlib>

void WorldserverCLI::DatabaseItemUniqueIds(int argc, char **argv, argh::parser &cmd, std::string &description)
{
	description = "Runs item_unique_id preflight, migration, and verification tasks";

	std::vector<std::string> arguments = {};
	std::vector<std::string> options = {
		"--preflight",
		"--migrate",
		"--verify",
		"--verbose",
		"--keep-trading-state",
	};

	if (cmd[{"-h", "--help"}]) {
		return;
	}

	EQEmuCommand::ValidateCmdInput(arguments, options, cmd, argc, argv);

	const bool verbose = cmd[{"-v", "--verbose"}];
	const bool migrate = cmd[{"--migrate"}];
	const bool verify  = cmd[{"--verify"}];
	const bool preflight = cmd[{"--preflight"}] || (!migrate && !verify);
	const bool clear_trading_state = !cmd[{"--keep-trading-state"}];
	bool success = true;

	if (preflight) {
		success = database.PreflightItemUniqueIdMigration(verbose) && success;
	}

	if (migrate) {
		if (!database.MigrateItemUniqueIdData(clear_trading_state, verbose)) {
			LogError("Item unique id migration failed verification");
			success = false;
		}
	}

	if (verify) {
		if (!database.VerifyItemUniqueIdMigration(verbose)) {
			LogError("Item unique id verification failed");
			success = false;
		}
	}

	if (!success) {
		std::exit(1);
	}
}
