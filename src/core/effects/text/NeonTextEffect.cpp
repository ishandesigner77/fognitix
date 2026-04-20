#include "NeonTextEffect.h"

namespace Fognitix::Effects {

NeonTextEffect::NeonTextEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view NeonTextEffect::typeId() const noexcept
{
    return "neon_text_effect";
}

void NeonTextEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
