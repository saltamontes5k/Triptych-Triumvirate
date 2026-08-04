/**
 * @file pet_window.h
 * @brief PetWindow — displays secondary pet HP gauges in the Pet Info Window
 *        and populates XTarget slots so all pets show HP bars.
 *
 * Finds the in-game CPetInfoWnd, locates CGaugeWnd children named "Pet 2"
 * and "Pet 3" (added via XML), and updates them each pulse with HP data
 * from MultiPet's tracked secondary pets.
 *
 * Hooks CSidlScreenWnd::WndNotification so clicking a secondary pet gauge
 * targets that pet.
 */

#pragma once

#include <cstdint>
#include <vector>

#include "multi_pet.h"  // TrackedPet

class PetWindow
{
public:
    bool Initialize();
    void Shutdown();
    void OnPulse();
    void OnSetGameState(int gameState);

    // Drop every cached pointer into EQ's pet window and force a re-locate on the next
    // pulse. Must be called whenever EQ tears its UI down (/loadskin, camp) or the
    // cached gauges dangle and OnPulse writes into freed memory.
    void ResetUI();

    // Find and cache the Pet Info Window pointer
    void* FindPetInfoWnd();

    // Walk pet window children, cache gauge pointers for Pet 2 and Pet 3
    void CreateGauge();

    // Handle click on a secondary pet gauge — returns true if handled
    bool HandleClick(void* sender);

    static PetWindow* GetInstance();

private:
    void UpdateGauge(void* gauge, const char* petName, int hpPercent);

    // THE list of pets the extra gauges represent, in gauge order: every tracked pet
    // except the one in the native pet window, focused-pet filter applied per call.
    // Display (OnPulse) and click handling (HandleClick) MUST both use this — they
    // once built their lists independently, the filters drifted, and clicking a
    // gauge targeted a different pet than the gauge displayed.
    std::vector<const TrackedPet*> GetVisiblePets();

    void* m_petInfoWnd  = nullptr;
    void* m_newGauge1   = nullptr;  // Pet 2 gauge
    void* m_newGauge2   = nullptr;  // Pet 3 gauge
    bool  m_initialized = false;    // true after gauges are cached
    int   m_initCounter = 0;        // delayed-init pulse counter
};
