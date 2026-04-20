#include "GlitchTextEffect.h"

namespace Fognitix::Effects {

GlitchTextEffect::GlitchTextEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view GlitchTextEffect::typeId() const noexcept
{
    return "glitch_text_effect";
}

void GlitchTextEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
