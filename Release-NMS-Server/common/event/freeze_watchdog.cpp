#include "freeze_watchdog.h"

#include "../eqemu_logsys.h"
#include "../path_manager.h"

#include <cstdio>
#include <ctime>
#include <filesystem>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <dbghelp.h>
#include <process.h>
#endif

namespace EQ
{
	FreezeWatchdog &FreezeWatchdog::Get()
	{
		static FreezeWatchdog instance;
		return instance;
	}

	FreezeWatchdog::~FreezeWatchdog()
	{
		m_running = false;
		m_cv.notify_all();

		if (m_thread.joinable()) {
			m_thread.join();
		}
	}

	uint64_t FreezeWatchdog::NowMs()
	{
		return static_cast<uint64_t>(
			std::chrono::duration_cast<std::chrono::milliseconds>(
				std::chrono::steady_clock::now().time_since_epoch()
			).count()
		);
	}

	void FreezeWatchdog::Start(std::function<std::string()> id, uint64_t stalling_after, uint64_t poll_interval)
	{
		if (m_running.exchange(true)) {
			// Already started; heartbeat-only calls are the common case here.
			return;
		}

		m_id                 = std::move(id);
		m_stalling_after_ms  = stalling_after;
		m_poll_interval_ms   = poll_interval;
		m_last_heartbeat_ms  = NowMs();

		m_thread = std::thread(&FreezeWatchdog::Monitor, this);

		LogInfo(
			"Freeze watchdog armed: reporting if the main loop does not tick for [{}] ms",
			m_stalling_after_ms
		);
	}

	void FreezeWatchdog::Heartbeat()
	{
		m_last_heartbeat_ms.store(NowMs(), std::memory_order_relaxed);
	}

	void FreezeWatchdog::Monitor()
	{
		while (m_running.load()) {
			{
				std::unique_lock<std::mutex> lock(m_mutex);
				m_cv.wait_for(lock, std::chrono::milliseconds(m_poll_interval_ms));
			}

			if (!m_running.load()) {
				break;
			}

			const uint64_t now       = NowMs();
			const uint64_t last_seen = m_last_heartbeat_ms.load(std::memory_order_relaxed);

			if (last_seen == 0 || now < last_seen) {
				continue;
			}

			const uint64_t stalled_for = now - last_seen;

			if (stalled_for < m_stalling_after_ms) {
				continue;
			}

			++m_freeze_episodes;

			// Resolved now rather than at Start(), because a dynamic zone only knows
			// its name once it has booted.
			std::string id = "unknown";
			if (m_id) {
				id = m_id();
			}

			LogError(
				"MAIN LOOP STALLED: [{}] has not completed a tick in [{}] ms (episode [{}]). "
				"Clients will see lag then a disconnect; nothing has faulted, so no crash "
				"report would otherwise be written.",
				id,
				stalled_for,
				m_freeze_episodes
			);

			const std::string dump_path = TryWriteFreezeDump();

			if (!dump_path.empty()) {
				LogError("MAIN LOOP STALLED: wrote minidump [{}] -- inspect the hung stack there.", dump_path);
			}

			// Do not re-report until the loop actually runs again, otherwise this
			// would log once per poll interval for as long as the stall lasts.
			m_last_heartbeat_ms.store(now, std::memory_order_relaxed);
		}
	}

	std::string FreezeWatchdog::TryWriteFreezeDump()
	{
#ifdef _WIN32
		// Keep the filename to characters that are safe on every filesystem we run on.
		std::string safe_id;
		const std::string resolved_id = m_id ? m_id() : std::string("server");
		for (const char c : resolved_id) {
			if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
				(c >= '0' && c <= '9') || c == '_' || c == '-') {
				safe_id.push_back(c);
			}
		}

		if (safe_id.empty()) {
			safe_id = "server";
		}

		// Use the resolved log path, not a cwd-relative one: a process started from the
		// wrong directory would otherwise drop its freeze dump where nobody looks.
		const std::string freeze_log_path = PathManager::Instance()->GetLogPath();
		const std::string freeze_crash_dir =
			freeze_log_path.empty() ? std::string("logs/crashes") : freeze_log_path + "/crashes";

		std::error_code ec;
		std::filesystem::create_directories(freeze_crash_dir, ec);

		char time_stamp[32] = {0};
		std::time_t now     = std::time(nullptr);
		std::tm     tm_buf{};
		if (localtime_s(&tm_buf, &now) == 0) {
			std::snprintf(
				time_stamp,
				sizeof(time_stamp),
				"%04d%02d%02d_%02d%02d%02d",
				tm_buf.tm_year + 1900,
				tm_buf.tm_mon + 1,
				tm_buf.tm_mday,
				tm_buf.tm_hour,
				tm_buf.tm_min,
				tm_buf.tm_sec
			);
		}
		else {
			std::snprintf(time_stamp, sizeof(time_stamp), "unknown");
		}

		const std::string path = freeze_crash_dir + "/freeze_" + safe_id + "_" +
			std::to_string(_getpid()) + "_" + time_stamp + ".dmp";

		const HANDLE file = CreateFileA(
			path.c_str(),
			GENERIC_WRITE,
			0,
			nullptr,
			CREATE_ALWAYS,
			FILE_ATTRIBUTE_NORMAL,
			nullptr
		);

		if (file == INVALID_HANDLE_VALUE) {
			LogError("MAIN LOOP STALLED: could not open [{}] for the minidump", path);
			return "";
		}

		// No exception information: nothing faulted, that is the whole point. The
		// thread list and stacks are what we want, so the dump is written from this
		// monitor thread against the live process.
		const MINIDUMP_TYPE type = static_cast<MINIDUMP_TYPE>(
			MiniDumpWithThreadInfo | MiniDumpWithIndirectlyReferencedMemory
		);

		const BOOL ok = MiniDumpWriteDump(
			GetCurrentProcess(),
			GetCurrentProcessId(),
			file,
			type,
			nullptr,
			nullptr,
			nullptr
		);

		CloseHandle(file);

		if (!ok) {
			LogError("MAIN LOOP STALLED: MiniDumpWriteDump failed (error [{}])", GetLastError());
			return "";
		}

		return path;
#else
		// Linux/FreeBSD: a stack walk of a live process needs external tooling, so
		// leave the report to the log line rather than pretending otherwise.
		return "";
#endif
	}
}
