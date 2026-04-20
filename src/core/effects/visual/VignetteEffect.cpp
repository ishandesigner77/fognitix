#include "VignetteEffect.h"

namespace Fognitix::Effects {

VignetteEffect::VignetteEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view VignetteEffect::typeId() const noexcept
{
    return "vignette_effect";
}

void VignetteEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
