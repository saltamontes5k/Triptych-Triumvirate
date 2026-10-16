#ifndef UCS_H
#define UCS_H

#include "../common/types.h"
#include "../common/net/servertalk_server_connection.h"
#include "../common/servertalk.h"
#include "../common/event/timer.h"
#include <chrono>
#include <memory>

class UCSConnection
{
public:
	UCSConnection();
	//! Returns false if the connection was refused because a live UCS already holds
	//! the slot; the caller must not advertise a UCS state change in that case.
	bool SetConnection(std::shared_ptr<EQ::Net::ServertalkServerConnection> connection);
	void ProcessPacket(uint16 opcode, EQ::Net::Packet &p);
	void SendPacket(ServerPacket* pack);
	void Disconnect() { if(connection && connection->Handle()) connection->Handle()->Disconnect(); }
	void SendMessage(const char *From, const char *Message);
	const std::shared_ptr<EQ::Net::ServertalkServerConnection> &GetConnection() const;
	inline bool IsConnected() const { return (connection && connection->Handle()) ? connection->Handle()->IsConnected() : false; }

	static UCSConnection* Instance()
	{
		static UCSConnection instance;
		return &instance;
	}

private:
	//! Rate limited reporting for refused duplicate UCS registrations.
	void NoteDuplicateRejection(const std::shared_ptr<EQ::Net::ServertalkServerConnection> &connection);

	inline std::string GetIP() const { return (connection && connection->Handle()) ? connection->Handle()->RemoteIP() : std::string(); }
	std::shared_ptr<EQ::Net::ServertalkServerConnection> connection;

	uint32                                m_duplicate_rejections = 0;
	std::chrono::steady_clock::time_point m_duplicate_window_start;
	bool                                  m_duplicate_logged = false;
};

#endif /*UCS_H_*/
