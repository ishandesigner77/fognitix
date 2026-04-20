#include "GlitchEffect.h"

namespace Fognitix::Effects {

GlitchEffect::GlitchEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view GlitchEffect::typeId() const noexcept
{
    return "glitch_effect";
}

void GlitchEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
