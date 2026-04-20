#include "ReverbEffect.h"

namespace Fognitix::Effects {

ReverbEffect::ReverbEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ReverbEffect::typeId() const noexcept
{
    return "reverb_effect";
}

void ReverbEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
