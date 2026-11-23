#include <string>
#include <memory>
#include "process.h"
#include <fmt/format.h>

#include <chrono>
#include <future>

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

int Process::execute_status_bounded(const std::string &cmd, std::string *output, int timeout_ms)
{
	// std::async's future joins in its destructor, which would block exactly like the
	// unbounded call; leak the future so a timed-out child cannot stall the caller. The
	// worker thread stays parked on the child's pipe -- one leaked thread per timeout,
	// documented in process.h.
	auto *run = new std::future<int>(std::async(
		std::launch::async,
		[&cmd, output]() -> int { return Process::execute_status(cmd, output); }
	));

	if (run->wait_for(std::chrono::milliseconds(timeout_ms)) != std::future_status::ready) {
		delete run;
		return -2;
	}

	const int status = run->get();
	delete run;
	return status;
}
