/**
 * @file who_multiclass.cpp
 * @brief Implementation of WhoMulticlass mod.
 *
 * Intercepts OP_WhoAllResponse (ROF2 opcode 0x578c) and reformats the output
 * to display NMS multi-class characters correctly.
 *
 * The server sends a class bitmask when multiclassing is enabled:
 *   Bit 0=Warrior, Bit 1=Cleric, ... Bit 15=Berserker
 * The standard client only understands class IDs 1-16, so multi-class values
 * show as "Unknown (Unknown)". We intercept the packet, decode the bitmask,
 * and output a formatted who list matching the Pyrelight DLL format:
 *   * GM *  Morsal - Level 100 Iksar  (Shaman/Necromancer/Magician)
 *
 * @date 2026-02-14
 *
 * @copyright Copyright (c) 2026
 */

#include <Windows.h>
#include "MQ2Main.h"
#include "who_multiclass.h"
#include "core_log.h"



#include <cstdint>
#include <cstring>
#include <string>
#include <cstdarg>

static void WriteWhof(const char* format, ...)
{
    char buffer[2048];
    va_list args;
    va_start(args, format);
    _vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    WriteChatColor(buffer, USERCOLOR_WHO);
}


// ---------------------------------------------------------------------------
// Opcode
// ---------------------------------------------------------------------------
static constexpr uint32_t OP_WhoAllResponse = 0x578c;

// ---------------------------------------------------------------------------
// Static instance pointer
// ---------------------------------------------------------------------------
static WhoMulticlass* s_instance = nullptr;

WhoMulticlass* WhoMulticlass::GetInstance() { return s_instance; }

// ---------------------------------------------------------------------------
// Class bitmask → name table (bit position → class name)
// ---------------------------------------------------------------------------
static const char* s_classNames[] = {
    "WAR", // bit 0  (1)
    "CLR", // bit 1  (2)
    "PAL", // bit 2  (4)
    "RNG", // bit 3  (8)
    "SHD", // bit 4  (16)
    "DRU", // bit 5  (32)
    "MNK", // bit 6  (64)
    "BRD", // bit 7  (128)
    "ROG", // bit 8  (256)
    "SHM", // bit 9  (512)
    "NEC", // bit 10 (1024)
    "WIZ", // bit 11 (2048)
    "MAG", // bit 12 (4096)
    "ENC", // bit 13 (8192)
    "BST", // bit 14 (16384)
    "BER", // bit 15 (32768)
};

static constexpr int s_numClasses = 16;

// Standard EQ class IDs (1-based) → name
static const char* GetSingleClassName(uint32_t classId)
{
    if (classId >= 1 && classId <= 16)
        return s_classNames[classId - 1];
    return "Unknown";
}

// Decode a class bitmask into "Class1/Class2/Class3" format
static std::string DecodeClassBitmask(uint32_t classBits)
{
    std::string result;
    for (int i = 0; i < s_numClasses; ++i)
    {
        if (classBits & (1u << i))
        {
            if (!result.empty())
                result += "/";
            result += s_classNames[i];
        }
    }
    return result.empty() ? "Unknown" : result;
}

// Check if a value is a multiclass bitmask (more than one bit set)
static bool IsMulticlass(uint32_t classValue)
{
    return (classValue & (classValue - 1)) != 0;
}

// ---------------------------------------------------------------------------
// Race ID → name table
// ---------------------------------------------------------------------------
static const char* GetRaceName(uint32_t raceId)
{
    switch (raceId)
    {
        case 1:   return "Human";
        case 2:   return "Barbarian";
        case 3:   return "Erudite";
        case 4:   return "Wood Elf";
        case 5:   return "High Elf";
        case 6:   return "Dark Elf";
        case 7:   return "Half Elf";
        case 8:   return "Dwarf";
        case 9:   return "Troll";
        case 10:  return "Ogre";
        case 11:  return "Halfling";
        case 12:  return "Gnome";
        case 128: return "Iksar";
        case 130: return "Vah Shir";
        case 330: return "Froglok";
        case 522: return "Drakkin";
        default:  return "Unknown";
    }
}

// ---------------------------------------------------------------------------
// GM rank string IDs
// ---------------------------------------------------------------------------
static const char* GetRankTag(uint32_t rankMsgId)
{
    switch (rankMsgId)
    {
        case 5007: return " * GM-Admin * ";
        case 5008: return " * ApprenticeGuide * ";
        case 5009: return " * Guide * ";
        case 5010: return " * ElderGuide * ";
        case 5011: return " * QuestMaster * ";
        case 5012: return " * GM * ";
        case 5013: return " * GM-Areas * ";
        case 5014: return " * GM-Coder * ";
        case 5015: return " * GM-Customer Service * ";
        case 5016: return " * GM-Event * ";
        case 5017: return " * GM-Lead Admin * ";
        case 5018: return " * GM-Lead Guide * ";
        case 5019: return " * GM-Loot * ";
        case 5020: return " * GMMgmt * ";
        case 5021: return " * GM-Impossible * ";
        case 12315: return " TRADER ";
        case 6056:  return " BUYER ";
        default:    return "";
    }
}


// ---------------------------------------------------------------------------
// Packet parsing helpers
// ---------------------------------------------------------------------------

// Safe read of a uint32 from buffer with bounds checking
static bool ReadUint32(const uint8_t* buf, uint32_t size, uint32_t& offset, uint32_t& out)
{
    if (offset + 4 > size) return false;
    memcpy(&out, buf + offset, 4);
    offset += 4;
    return true;
}

// Safe read of a null-terminated string
static bool ReadString(const uint8_t* buf, uint32_t size, uint32_t& offset, char* out, uint32_t maxLen)
{
    uint32_t start = offset;
    while (offset < size && buf[offset] != '\0')
        offset++;

    if (offset >= size) return false;  // No null terminator found

    uint32_t len = offset - start;
    if (len >= maxLen) len = maxLen - 1;
    memcpy(out, buf + start, len);
    out[len] = '\0';
    offset++;  // Skip the null terminator
    return true;
}

// ---------------------------------------------------------------------------
// IMod interface
// ---------------------------------------------------------------------------

const char* WhoMulticlass::GetName() const
{
    return "WhoMulticlass";
}

bool WhoMulticlass::Initialize()
{
    s_instance = this;
    SimpleLog("WhoMulticlass: Initializing...");
    SimpleLog("WhoMulticlass: Listening for OP_WhoAllResponse (0x%04X)", OP_WhoAllResponse);
    SimpleLog("WhoMulticlass: Initialized");


    return true;
}

void WhoMulticlass::Shutdown()
{
    SimpleLog("WhoMulticlass: Shutdown");


    s_instance = nullptr;
}


void WhoMulticlass::OnPulse()
{
    // No per-frame work needed
}

bool WhoMulticlass::OnIncomingMessage(uint32_t opcode, const void* buffer, uint32_t size)
{
    if (opcode == OP_WhoAllResponse && buffer && size > 0x40)
    {
        if (HandleWhoResponse(buffer, size))
            return false;  // Suppress original — we've generated our own output
    }

    return true;  // Pass through all other messages
}

// ---------------------------------------------------------------------------
// Who response packet parsing and reformatting
// ---------------------------------------------------------------------------

bool WhoMulticlass::HandleWhoResponse(const void* buffer, uint32_t size)
{
    const uint8_t* buf = static_cast<const uint8_t*>(buffer);
    uint32_t offset = 0;

    // --- Parse header (WhoAllReturnStruct) ---
    // 0x00: uint32 id
    // 0x04: uint32 playerineqstring
    // 0x08: char[27] line
    // 0x23: uint8 unknown35
    // 0x24: uint32 unknown36
    // 0x28: uint32 playersinzonestring
    // 0x2C: uint32 unknown44[2]
    // 0x34: uint32 unknown52
    // 0x38: uint32 unknown56
    // 0x3C: uint32 playercount

    if (size < 0x40)
        return false;

    uint32_t playerCount;
    memcpy(&playerCount, buf + 0x3C, 4);

    SimpleLog("WhoMulticlass: Processing who response — %u player(s)", playerCount);



    offset = 0x40;  // Skip header

    // --- Parse each player entry ---
    for (uint32_t i = 0; i < playerCount; ++i)
    {
        uint32_t formatMsgId, padding1, padding2;
        char     name[64] = {};
        uint32_t rankMsgId;
        char     guild[128] = {};
        uint32_t unknown80_0, unknown80_1;
        uint32_t zoneMsgId, zone;
        uint32_t classValue, level, race;
        char     account[64] = {};
        uint32_t ending;

        if (!ReadUint32(buf, size, offset, formatMsgId)) return false;
        if (!ReadUint32(buf, size, offset, padding1))    return false;
        if (!ReadUint32(buf, size, offset, padding2))    return false;
        if (!ReadString(buf, size, offset, name, sizeof(name))) return false;
        if (!ReadUint32(buf, size, offset, rankMsgId))   return false;
        if (!ReadString(buf, size, offset, guild, sizeof(guild))) return false;
        if (!ReadUint32(buf, size, offset, unknown80_0)) return false;
        if (!ReadUint32(buf, size, offset, unknown80_1)) return false;
        if (!ReadUint32(buf, size, offset, zoneMsgId))   return false;
        if (!ReadUint32(buf, size, offset, zone))        return false;
        if (!ReadUint32(buf, size, offset, classValue))  return false;
        if (!ReadUint32(buf, size, offset, level))       return false;
        if (!ReadUint32(buf, size, offset, race))        return false;
        if (!ReadString(buf, size, offset, account, sizeof(account))) return false;
        if (!ReadUint32(buf, size, offset, ending))      return false;

        // --- Format the output line ---
        const char* raceName = GetRaceName(race);

        std::string classStr;
        if (IsMulticlass(classValue))
            classStr = DecodeClassBitmask(classValue);
        else if (classValue >= 1 && classValue <= 16)
            classStr = GetSingleClassName(classValue);
        else if (classValue != 0)
            classStr = DecodeClassBitmask(classValue);  // Single class as bitmask
        else
            classStr = "Unknown";

        char rankTag[64];
        strncpy_s(rankTag, GetRankTag(rankMsgId), _TRUNCATE);

        char zoneStr[64] = "";
        if (zoneMsgId == 5006) { // "ZONE: %1"
            PCHAR szZone = GetShortZone(zone);
            if (szZone) {
                sprintf_s(zoneStr, " ZONE: %s", szZone);
            }
        }

        // Standard NMS Format: [Name] - [Level CLASSES (Race)] ZONE: zone * RANK *
        if (formatMsgId == 5024) // Fully Anonymous
        {
            WriteWhof("[%s] - [ANONYMOUS]%s%s", name, zoneStr, rankTag);
        }
        else if (formatMsgId == 5023) // Roleplay (Partially Anonymous in standard, but NMS treats it as Roleplay tag)
        {
            WriteWhof("[%s] - [%u %s (%s)] <ROLEPLAY>%s%s", 
                name, level, classStr.c_str(), raceName, zoneStr, rankTag);
        }
        else
        {
            WriteWhof("[%s] - [%u %s (%s)]%s%s",
                name, level, classStr.c_str(), raceName, zoneStr, rankTag);
        }

    }

    // --- Output footer ---
    if (playerCount == 0)
        WriteWhof("There are no players in EverQuest that match those who filters.");
    else if (playerCount == 1)
        WriteWhof("There is %u player in EverQuest.", playerCount);
    else
        WriteWhof("There are %u players in EverQuest.", playerCount);

    return true;
}

