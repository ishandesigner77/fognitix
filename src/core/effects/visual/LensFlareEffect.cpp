#include "LensFlareEffect.h"

namespace Fognitix::Effects {

LensFlareEffect::LensFlareEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LensFlareEffect::typeId() const noexcept
{
    return "lens_flare_effect";
}

void LensFlareEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
