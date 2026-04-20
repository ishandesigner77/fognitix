#include "GlowEffect.h"

namespace Fognitix::Effects {

GlowEffect::GlowEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view GlowEffect::typeId() const noexcept
{
    return "glow_effect";
}

void GlowEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
