#include "ExposureEffect.h"

namespace Fognitix::Effects {

ExposureEffect::ExposureEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ExposureEffect::typeId() const noexcept
{
    return "exposure_effect";
}

void ExposureEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
