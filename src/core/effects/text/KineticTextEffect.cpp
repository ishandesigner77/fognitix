#include "KineticTextEffect.h"

namespace Fognitix::Effects {

KineticTextEffect::KineticTextEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view KineticTextEffect::typeId() const noexcept
{
    return "kinetic_text_effect";
}

void KineticTextEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
