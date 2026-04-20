#include "SaturationEffect.h"

namespace Fognitix::Effects {

SaturationEffect::SaturationEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view SaturationEffect::typeId() const noexcept
{
    return "saturation_effect";
}

void SaturationEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
