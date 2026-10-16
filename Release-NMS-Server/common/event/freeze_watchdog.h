#pragma once

#include <atomic>
#include <chrono>
#include <functional>
#include <condition_variable>
#include <cstdint>
#include <mutex>
#include <string>
#include <thread>

/**
 * Detects a stalled main loop.
 *
 * The server processes run their whole simulation on the main thread: zone's
 * per-tick work is a 32 ms EQ::Timer callback inside the libuv loop
 * (zone/main.cpp), and the same shape is used elsewhere. When that thread stops
 * returning -- an unbounded loop, a blocking write, a deadlock -- the process
 * stays alive but stops answering clients. From the client that looks like a
 * lag spike followed by the connection bar falling and eventually an
 * ICMP port-unreachable disconnect, and on disk it looks like a log that simply
 * stops mid-write, with no crash report, because nothing actually faulted.
 *
 * That is exactly the 2026-10-11 Plane of Torment stalls. This watchdog makes
 * the next one self-reporting: the loop calls Heartbeat() every tick, and a
 * monitor thread notes when the heartbeat goes stale. On Windows it also tries
 * to write a minidump so the hung stack can be inspected after the fact.
 *
 * Usage (from the server that owns the loop):
 *
 *     FreezeWatchdog::Get().Start("potorment", 15000, 5000);
 *     // ... inside the per-tick callback, on every return path ...
 *     FreezeWatchdog::Get().Heartbeat();
 */
namespace EQ
{
	class FreezeWatchdog
	{
	public:
		// Singleton with static storage: the monitor thread is detached and must
		// outlive any caller's scope.
		static FreezeWatchdog &Get();

		// id is only used in the log line / dump filename.
		// stalling_after / poll_interval are milliseconds.
		// id is only used in the log line / dump filename. It is a callable because
		// for a dynamic zone the useful name is not known until the zone is booted,
		// well after the watchdog needs to be armed.
		void Start(std::function<std::string()> id, uint64_t stalling_after = 15000, uint64_t poll_interval = 5000);

		// Call once per main-loop tick.
		void Heartbeat();

		bool IsRunning() const { return m_running.load(); }

	private:
		FreezeWatchdog() = default;
		~FreezeWatchdog();

		FreezeWatchdog(const FreezeWatchdog &) = delete;
		FreezeWatchdog &operator=(const FreezeWatchdog &) = delete;

		void Monitor();

		// Best-effort, Windows only. Returns the path written, or an empty string.
		std::string TryWriteFreezeDump();

		static uint64_t NowMs();

		std::function<std::string()> m_id;
		std::atomic<uint64_t>   m_last_heartbeat_ms{0};
		std::atomic<bool>       m_running{false};
		uint64_t                m_stalling_after_ms{15000};
		uint64_t                m_poll_interval_ms{5000};
		uint64_t                m_freeze_episodes{0};
		std::thread             m_thread;
		std::mutex              m_mutex;
		std::condition_variable m_cv;
	};
}
