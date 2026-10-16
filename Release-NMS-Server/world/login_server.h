#ifndef LOGINSERVER_H
#define LOGINSERVER_H

#include "../common/servertalk.h"
#include "../common/linked_list.h"
#include "../common/timer.h"
#include "../common/queue.h"
#include "../common/eq_packet_structs.h"
#include "../common/mutex.h"
#include "../common/net/servertalk_client_connection.h"
#include "../common/net/servertalk_legacy_client_connection.h"
#include "../common/event/timer.h"
#include <memory>

class LoginServer{
public:
	LoginServer(const char*, uint16, const char*, const char*, bool legacy);
	~LoginServer();

	bool Connect();
	void SendInfo();
	void SendStatus();

	void SendPacket(ServerPacket* pack);
	void SendAccountUpdate(ServerPacket *pack);
	// Guards against the loginserver-registration storm. EQ::Net::ServertalkClient
	// retries its connection on a 100 ms timer, and the loginserver answers a
	// duplicate world name by destroying the connection the world is currently on
	// (WorldServerManager::DestroyServerByName -> Disconnect). The world then sees
	// the drop, reconnects 100 ms later, and lands in the same duplicate state
	// again -- measured at 9-10 registrations per second for ~25 minutes on
	// 2026-10-10, accumulating until world.exe faulted. Allowing a fixed number of
	// attempts per window keeps a transient duplicate (a loginserver that has just
	// restarted, say) recoverable, but stops the unbounded loop.
	bool ShouldAcceptReconnectAttempt();

	// Deferred disconnects for a connection we have decided not to use. See the
	// definitions in login_server.cpp for why this cannot be a direct reset.
	void CloseRejectedConnection(std::shared_ptr<EQ::Net::TCPConnection> connection);

	bool Connected()
	{
		if (m_is_legacy) {
			if (m_legacy_client) {
				return m_legacy_client->Connected();
			}
		}
		else {
			if (m_client) {
				return m_client->Connected();
			}
		}

		return false;
	}
	bool CanUpdate() { return m_can_account_update; }

private:
	void ProcessUsertoWorldReqLeg(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessUsertoWorldReq(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessLSClientAuth(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessLSClientAuthLegacy(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessLSFatalError(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessSystemwideMessage(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessLSRemoteAddr(uint16_t opcode, EQ::Net::Packet &p);
	void ProcessLSAccountUpdate(uint16_t opcode, EQ::Net::Packet &p);

	std::unique_ptr<EQ::Timer> m_keepalive;

	// see ShouldAcceptReconnectAttempt()
	std::chrono::steady_clock::time_point m_reconnect_window_start;
	uint32                                 m_reconnect_attempts = 0;
	bool                                   m_reconnect_storm_logged = false;

	std::unique_ptr<EQ::Net::ServertalkClient>       m_client;
	std::unique_ptr<EQ::Net::ServertalkLegacyClient> m_legacy_client;
	std::unique_ptr<EQ::Timer>                       m_statusupdate_timer;
	char                                             m_loginserver_address[256];
	uint32                                           m_loginserver_ip;
	uint16                                           m_loginserver_port;
	std::string                                      m_login_account;
	std::string                                      m_login_password;
	bool                                             m_can_account_update;
	bool                                             m_is_legacy;
};
#endif
