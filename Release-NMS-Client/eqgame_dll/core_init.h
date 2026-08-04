#include "core_bazaar.h"
#include "core_map.h"
#include "core_npc.h"
#include "core_item.h"
#include "core_eqg_load.h"
#include "core_zone.h"
#include "core_luclin_models.h"
#include "_options.h"

// InitOptions is called during the initialization of this hook
void InitOptions() {
	if (areLuclinModelsDisabled) DisableLuclinModels();
	if (isMapWindowDisabled) DisableCMapViewWnd();
	if (areCustomZonesEnabled) InjectCustomZones();
	if (areCustomNPCsEnabled) InjectCustomNPCs();
	if (areCustomOldAnimationsEnabled) InjectCustomOldAnimations();
	if (isBazaarWindowDisabled) DisableCBazaarSearchWnd();
	if (isEQGOverrideEnabled) InjectEQGOrderLoading();
	if (areCustomShieldsEnabled) InjectCustomShields();
}