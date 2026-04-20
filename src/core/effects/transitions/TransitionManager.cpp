#include "TransitionManager.h"

namespace Fognitix::Effects {

TransitionManager::TransitionManager(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TransitionManager::typeId() const noexcept
{
    return "transition_manager";
}

void TransitionManager::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
