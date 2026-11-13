#include <string>
#include <memory>
#include "process.h"
#include <fmt/format.h>

#if !_WIN32
#include <sys/wait.h>
#endif

std::string Process::execute(const std::string &cmd)
{
	std::string           command = fmt::format("{} 2>&1", cmd);
	std::shared_ptr<FILE> pipe(popen(command.c_str(), "r"), pclose);
	if (!pipe) { return "ERROR"; }
	char        buffer[128];
	std::string result;
	while (!feof(pipe.get())) {
		if (fgets(buffer, 128, pipe.get()) != nullptr) {
			result += buffer;
		}
	}

	return result;
}

int Process::execute_status(const std::string &cmd, std::string *output)
{
	std::string command = fmt::format("{} 2>&1", cmd);
	FILE       *pipe    = popen(command.c_str(), "r");
	if (!pipe) { return -1; }

	if (output) {
		char buffer[128];
		while (!feof(pipe)) {
			if (fgets(buffer, 128, pipe) != nullptr) {
				*output += buffer;
			}
		}
	}

	int status = pclose(pipe);

#if _WIN32
	return status;
#else
	return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
#endif
}
