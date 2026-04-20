#include "ChromaticEffect.h"

namespace Fognitix::Effects {

ChromaticEffect::ChromaticEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ChromaticEffect::typeId() const noexcept
{
    return "chromatic_effect";
}

void ChromaticEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
