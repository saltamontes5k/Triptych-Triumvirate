#pragma once

#include <array>
#include <cstddef>
#include <cstdint>
#include <optional>
#include <string_view>
#include <vector>

// RoF2 May 10, 2013 Monster Mission panel wire shapes. The Zone adapter must
// derive the task and character from the active session, never from opaque
// request fields. Mapping and profile installation are separate operations.
namespace Rof2MonsterTaskWire {

inline constexpr uint16_t CatalogueOpcode = 0x3c54;
inline constexpr uint16_t TemplateDetailsOpcode = 0x3d20;
inline constexpr uint16_t SelectRoleOpcode = 0x4eea;
inline constexpr uint16_t SelectionResultOpcode = 0x5a67;
inline constexpr std::size_t DetailRequestSize = 0x1010;

using Bytes = std::vector<uint8_t>;

enum class SelectionResult : uint32_t {
    Selected = 0,
    Ineligible = 1,
    UnknownFailure = 2,
    Unavailable = 3,
    Locked = 4,
    AlreadySelected = 5,
    InsideOtherMission = 6
};

struct CatalogueHeader {
    uint32_t task_id;
    std::array<uint32_t, 3> opaque_fields{};
    bool selection_locked = false;
};

struct Role {
    uint32_t template_id;
    uint32_t minimum;
    uint32_t maximum;
    uint32_t opaque_0c;
    bool available;
    std::string_view name;
};

inline uint32_t ReadU32(const uint8_t* data)
{
    return uint32_t(data[0]) | (uint32_t(data[1]) << 8) |
        (uint32_t(data[2]) << 16) | (uint32_t(data[3]) << 24);
}

inline void WriteU32(Bytes& out, uint32_t value)
{
    for (unsigned i = 0; i < 4; ++i) {
        out.push_back(static_cast<uint8_t>(value >> (8 * i)));
    }
}

inline bool IsCatalogueRequest(const uint8_t* data, std::size_t size)
{
    return data && size == 8;
}

inline std::optional<uint32_t> DecodeRoleRequest(const uint8_t* data, std::size_t size, std::size_t expected_size)
{
    if (!data || size < 12 || size != expected_size) {
        return std::nullopt;
    }
    const auto template_id = ReadU32(data + 8);
    if (!template_id) {
        return std::nullopt;
    }
    return template_id;
}

inline std::optional<uint32_t> DecodeSelection(const uint8_t* data, std::size_t size)
{
    return DecodeRoleRequest(data, size, 12);
}

inline std::optional<uint32_t> DecodeDetailsRequest(const uint8_t* data, std::size_t size)
{
    return DecodeRoleRequest(data, size, DetailRequestSize);
}

inline std::optional<Bytes> EncodeCatalogue(const CatalogueHeader& header, const std::vector<Role>& roles)
{
    if (!header.task_id || roles.size() > 6) {
        return std::nullopt;
    }
    Bytes out;
    out.reserve(21 + roles.size() * 81);
    WriteU32(out, header.opaque_fields[0]);
    WriteU32(out, header.opaque_fields[1]);
    // RoF2's catalogue parser matches the active shared task using wire offset 8.
    WriteU32(out, header.task_id);
    WriteU32(out, header.opaque_fields[2]);
    out.push_back(header.selection_locked);
    WriteU32(out, static_cast<uint32_t>(roles.size()));
    for (const auto& role : roles) {
        if (!role.template_id || (role.maximum && role.minimum > role.maximum) ||
            role.name.empty() || role.name.size() > 63 || role.name.find('\0') != std::string_view::npos) {
            return std::nullopt;
        }
        WriteU32(out, role.template_id);
        WriteU32(out, role.minimum);
        WriteU32(out, role.maximum);
        WriteU32(out, role.opaque_0c);
        out.push_back(role.available);
        out.insert(out.end(), role.name.begin(), role.name.end());
        out.push_back(0);
    }
    return out;
}

inline Bytes EncodeSelectionResult(uint32_t template_id, SelectionResult result,
    const std::array<uint32_t, 2>& opaque_fields = {})
{
    Bytes out;
    out.reserve(16);
    WriteU32(out, opaque_fields[0]);
    WriteU32(out, opaque_fields[1]);
    WriteU32(out, template_id);
    WriteU32(out, static_cast<uint32_t>(result));
    return out;
}

// The selector uses the ordinary template text reader after its separate
// 16-byte prefix. Use only owned catalogued templates and no player input text.
inline std::optional<Bytes> EncodeTemplateDetails(const std::array<uint32_t, 4>& prefix,
    std::string_view canonical_template_text)
{
    if (!prefix[2] || canonical_template_text.empty() || canonical_template_text.size() > 4095 ||
        canonical_template_text.find('\0') != std::string_view::npos) {
        return std::nullopt;
    }
    Bytes out;
    out.reserve(17 + canonical_template_text.size());
    for (const auto value : prefix) {
        WriteU32(out, value);
    }
    out.insert(out.end(), canonical_template_text.begin(), canonical_template_text.end());
    out.push_back(0);
    return out;
}

} // namespace Rof2MonsterTaskWire
