/**
 * @file mod_interface.h
 * @brief IMod base class — virtual interface for feature mods.
 */

#pragma once

#include <cstdint>

class IMod
{
public:
    virtual ~IMod() = default;

    virtual const char* GetName() const = 0;
    virtual bool        Initialize()    = 0;
    virtual void        Shutdown()      = 0;

    virtual void OnPulse() {}
    virtual bool OnIncomingMessage(uint32_t /*opcode*/, const void* /*buffer*/, uint32_t /*size*/) { return true; }
    virtual void OnAddSpawn(void* /*pSpawn*/) {}
    virtual void OnRemoveSpawn(void* /*pSpawn*/) {}
    virtual void OnSetGameState(int /*gameState*/) {}
};
