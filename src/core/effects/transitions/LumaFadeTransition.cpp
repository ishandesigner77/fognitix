#include "LumaFadeTransition.h"

namespace Fognitix::Effects {

LumaFadeTransition::LumaFadeTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LumaFadeTransition::typeId() const noexcept
{
    return "luma_fade_transition";
}

void LumaFadeTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
