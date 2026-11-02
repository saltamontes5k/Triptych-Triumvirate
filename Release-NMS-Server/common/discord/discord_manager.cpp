#include "discord_manager.h"
#include "../../common/discord/discord.h"
#include "../events/player_event_logs.h"

void DiscordManager::QueueWebhookMessage(uint32 webhook_id, const std::string &message)
{
	webhook_queue_lock.lock();
	webhook_message_queue[webhook_id].emplace_back(message);
	webhook_queue_lock.unlock();
}

constexpr int MAX_MESSAGE_LENGTH = 1900;

void DiscordManager::ProcessMessageQueue()
{
	// Take the queue under the lock, then do the HTTP posts outside it. This used to hold
	// webhook_queue_lock across every Discord::SendWebhookMessage -- a blocking HTTPS POST --
	// so any thread that logged a Discord-routed line blocked in QueueWebhookMessage for as
	// long as Discord took to answer. On 10-24 that wedged the whole UCS event loop: cdb
	// showed the main thread in DiscordManager::QueueWebhookMessage while the worker sat in
	// httplib::ClientImpl::Post, and chat keepalives stopped until every client timed out.
	std::map<uint32, std::vector<std::string>> pending;
	{
		std::lock_guard<std::mutex> lock(webhook_queue_lock);
		if (webhook_message_queue.empty()) {
			return;
		}
		pending.swap(webhook_message_queue);
	}

	for (auto &q: pending) {
		LogDiscord("Processing [{}] messages in queue for webhook ID [{}]...", q.second.size(), q.first);

		if (q.first >= MAX_DISCORD_WEBHOOK_ID) {
			LogDiscord("Out of bounds webhook ID [{}] max [{}]", q.first, MAX_DISCORD_WEBHOOK_ID);
			continue;
		}

		auto        webhook  = EQEmuLogSys::Instance()->GetDiscordWebhooks()[q.first];
		std::string message;

		for (auto &m: q.second) {
			// next message would become too large
			bool next_message_too_large = ((int) m.length() + (int) message.length()) > MAX_MESSAGE_LENGTH;
			if (next_message_too_large) {
				Discord::SendWebhookMessage(
					message,
					webhook.webhook_url
				);
				message.clear();
			}

			message += m;

			// one single message was too large
			// this should rarely happen but the message will need to be split
			if ((int) message.length() > MAX_MESSAGE_LENGTH) {
				for (unsigned mi = 0; mi < message.length(); mi += MAX_MESSAGE_LENGTH) {
					Discord::SendWebhookMessage(
						message.substr(mi, MAX_MESSAGE_LENGTH),
						webhook.webhook_url
					);
				}
				message.clear();
			}
		}
		// final flush
		if (!message.empty()) {
			Discord::SendWebhookMessage(
				message,
				webhook.webhook_url
			);
		}
	}
}

void DiscordManager::QueuePlayerEventMessage(const PlayerEvent::PlayerEventContainer& e)
{
	auto w = PlayerEventLogs::Instance()->GetDiscordWebhookUrlFromEventType(e.player_event_log.event_type_id);
	if (!w.empty()) {
		Discord::SendPlayerEventMessage(e, w);
	}
}
