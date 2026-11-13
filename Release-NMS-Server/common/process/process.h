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
};


#endif //EQEMU_PROCESS_H
