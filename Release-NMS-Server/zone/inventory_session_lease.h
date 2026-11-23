#pragma once
#include <array>
#include <cstdint>
#include <memory>
#include <string>

// Zone inventory admission lease. One active row per character; a clean Client
// deletion releases it. A crash leaves the row active by design (no takeover).
class InventorySessionLease {
public:
    static std::shared_ptr<InventorySessionLease> Claim(
        uint32_t character_id, uint32_t account_id, uint32_t zone_id, uint16_t instance_id,
        const std::string &process_key, const std::string &client_key);
    bool Held() const;
    bool Release();

private:
    uint32_t character_id_ = 0;
    uint32_t account_id_ = 0;
    uint32_t zone_id_ = 0;
    uint16_t instance_id_ = 0;
    uint64_t epoch_ = 0;
    std::array<uint8_t, 32> token_{};
    std::string process_key_;
    std::string client_key_;
    bool active_ = false;
};
