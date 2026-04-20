#include "LightLeakTransition.h"

namespace Fognitix::Effects {

LightLeakTransition::LightLeakTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LightLeakTransition::typeId() const noexcept
{
    return "light_leak_transition";
}

void LightLeakTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
