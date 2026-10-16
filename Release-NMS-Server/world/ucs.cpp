#include "../common/global_define.h"
#include "../common/eqemu_logsys.h"
#include "ucs.h"
#include "world_config.h"

#include "../common/misc_functions.h"
#include "../common/md5.h"
#include "../common/packet_dump.h"
#include "../common/event/timer.h"

UCSConnection::UCSConnection()
{
	connection = 0;
}

// A UCS that identifies itself while we already hold a live one used to evict the
// incumbent (the old "Incoming UCS Connection while we were already connected to a
// UCS" path). Two ucs.exe instances then evicted each other on their 100 ms
// reconnect timers forever -- measured at ~18 registrations/sec on 2026-10-10/11.
// Every cycle broadcast a UCS status change to every zone, and the zone handler
// force-reconnects each client on every one of them, so chat never settled; world
// also faulted during the storm. Keep the incumbent and reject the newcomer.
bool UCSConnection::SetConnection(std::shared_ptr<EQ::Net::ServertalkServerConnection> inStream)
{
	const bool incumbent_live =
		connection && connection->Handle() && connection->Handle()->IsConnected();

	if (inStream && incumbent_live) {
		NoteDuplicateRejection(inStream);
		return false;
	}

	connection = inStream;
	if (connection) {
		connection->OnMessage(
			std::bind(
				&UCSConnection::ProcessPacket,
				this,
				std::placeholders::_1,
				std::placeholders::_2
			)
		);
	}

	return true;
}

void UCSConnection::NoteDuplicateRejection(const std::shared_ptr<EQ::Net::ServertalkServerConnection> &inStream)
{
	const auto now = std::chrono::steady_clock::now();

	if (m_duplicate_window_start.time_since_epoch().count() == 0 ||
		now - m_duplicate_window_start >= std::chrono::seconds(30)) {
		m_duplicate_window_start = now;
		m_duplicate_rejections   = 0;
		m_duplicate_logged       = false;
	}

	++m_duplicate_rejections;

	if (!m_duplicate_logged) {
		m_duplicate_logged = true;

		LogError(
			"Refusing duplicate UCS connection from [{}] -- a UCS is already connected, "
			"so more than one ucs.exe must be running. Disconnecting the duplicate "
			"instead of evicting the live connection; refusal [{}] in this 30 second "
			"window, and further refusals in it are not logged.",
			(inStream && inStream->Handle()) ? inStream->Handle()->RemoteIP() : "unknown",
			m_duplicate_rejections
		);
	}

	if (inStream && inStream->Handle()) {
		// TCPConnection::Disconnect only queues uv_close, so this is safe to call from
		// inside the connection's own identification callback.
		inStream->Handle()->Disconnect();
	}
}

const std::shared_ptr<EQ::Net::ServertalkServerConnection> &UCSConnection::GetConnection() const
{
	return connection;
}

void UCSConnection::ProcessPacket(uint16 opcode, EQ::Net::Packet &p)
{
	if (!connection)
		return;

	ServerPacket tpack(opcode, p);
	ServerPacket *pack = &tpack;

	switch (opcode)
	{
		case 0:
			break;

		case ServerOP_KeepAlive:
		{
			// ignore this
			break;
		}
		case ServerOP_ZAAuth:
		{
			LogInfo("Got authentication from UCS when they are already authenticated");
			break;
		}
		default:
		{
			LogInfo("Unknown ServerOPcode from UCS {:#04x}, size [{}]", opcode, pack->size);
			DumpPacket(pack->pBuffer, pack->size);
			break;
		}
	}
}

void UCSConnection::SendPacket(ServerPacket* pack)
{
	if (!connection)
		return;

	connection->SendPacket(pack);
}

void UCSConnection::SendMessage(const char *From, const char *Message)
{
	auto pack = new ServerPacket(ServerOP_UCSMessage, strlen(From) + strlen(Message) + 2);

	char *Buffer = (char *)pack->pBuffer;

	VARSTRUCT_ENCODE_STRING(Buffer, From);
	VARSTRUCT_ENCODE_STRING(Buffer, Message);

	SendPacket(pack);
	safe_delete(pack);
}
