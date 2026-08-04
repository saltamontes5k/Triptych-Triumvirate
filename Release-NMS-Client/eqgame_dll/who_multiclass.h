/**
 * @file who_multiclass.h
 * @brief WhoMulticlass mod — reformats /who output to display NMS multi-class
 *        characters correctly instead of showing "Unknown (Unknown)".
 * @date 2026-02-14
 *
 * @copyright Copyright (c) 2026
 */

#pragma once

#include "mod_interface.h"

class WhoMulticlass : public IMod
{
public:
    const char* GetName() const override;
    bool        Initialize() override;
    void        Shutdown() override;
    void        OnPulse() override;
    bool        OnIncomingMessage(uint32_t opcode, const void* buffer, uint32_t size) override;

    static WhoMulticlass* GetInstance();

private:
    bool HandleWhoResponse(const void* buffer, uint32_t size);
};

