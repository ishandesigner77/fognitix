#include "WarpEffect.h"

namespace Fognitix::Effects {

WarpEffect::WarpEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view WarpEffect::typeId() const noexcept
{
    return "warp_effect";
}

void WarpEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
