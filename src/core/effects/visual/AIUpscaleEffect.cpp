#include "AIUpscaleEffect.h"

namespace Fognitix::Effects {

AIUpscaleEffect::AIUpscaleEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view AIUpscaleEffect::typeId() const noexcept
{
    return "a_i_upscale_effect";
}

void AIUpscaleEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
