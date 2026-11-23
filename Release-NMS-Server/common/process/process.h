#ifndef EQEMU_PROCESS_H
#define EQEMU_PROCESS_H

#include "../strings.h"

#include <cstdio>

#if _WIN32
#define popen _popen
#define pclose _pclose
#endif

class Process {
public:
	static std::string execute(const std::string &cmd);
	// Runs cmd like execute(), but also reports the child's exit status:
	// the child's exit code, or -1 when the process could not be started.
	// Output (stdout + stderr) is appended to *output when non-null.
	static int execute_status(const std::string &cmd, std::string *output);
	// execute_status with a hard wall-clock cap. Returns -2 when the child
	// exceeded timeout_ms: the worker thread stays parked on the child's
	// pipe (deliberately leaked -- killing it process-wide would need job
	// objects), the caller treats the run as failed and moves on. This is
	// what keeps a wedged child (the 2026-11-21 migration-backup boot hang)
	// from stalling a boot forever.
	static int execute_status_bounded(const std::string &cmd, std::string *output, int timeout_ms);
};


#endif //EQEMU_PROCESS_H
