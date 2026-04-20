#include "LowerThirdsEffect.h"

namespace Fognitix::Effects {

LowerThirdsEffect::LowerThirdsEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LowerThirdsEffect::typeId() const noexcept
{
    return "lower_thirds_effect";
}

void LowerThirdsEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
