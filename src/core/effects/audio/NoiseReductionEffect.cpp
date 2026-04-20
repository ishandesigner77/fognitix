#include "NoiseReductionEffect.h"

namespace Fognitix::Effects {

NoiseReductionEffect::NoiseReductionEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view NoiseReductionEffect::typeId() const noexcept
{
    return "noise_reduction_effect";
}

void NoiseReductionEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
