#include "AutoDuckEffect.h"

namespace Fognitix::Effects {

AutoDuckEffect::AutoDuckEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view AutoDuckEffect::typeId() const noexcept
{
    return "auto_duck_effect";
}

void AutoDuckEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
