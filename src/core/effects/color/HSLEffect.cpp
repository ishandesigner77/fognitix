#include "HSLEffect.h"

namespace Fognitix::Effects {

HSLEffect::HSLEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view HSLEffect::typeId() const noexcept
{
    return "h_s_l_effect";
}

void HSLEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
