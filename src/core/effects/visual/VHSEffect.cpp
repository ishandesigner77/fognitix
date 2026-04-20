#include "VHSEffect.h"

namespace Fognitix::Effects {

VHSEffect::VHSEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view VHSEffect::typeId() const noexcept
{
    return "v_h_s_effect";
}

void VHSEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
