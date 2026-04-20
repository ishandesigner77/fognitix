#include "HologramEffect.h"

namespace Fognitix::Effects {

HologramEffect::HologramEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view HologramEffect::typeId() const noexcept
{
    return "hologram_effect";
}

void HologramEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
