#include "GlitchTransition.h"

namespace Fognitix::Effects {

GlitchTransition::GlitchTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view GlitchTransition::typeId() const noexcept
{
    return "glitch_transition";
}

void GlitchTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
