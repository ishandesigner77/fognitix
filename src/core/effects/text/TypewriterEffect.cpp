#include "TypewriterEffect.h"

namespace Fognitix::Effects {

TypewriterEffect::TypewriterEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TypewriterEffect::typeId() const noexcept
{
    return "typewriter_effect";
}

void TypewriterEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
