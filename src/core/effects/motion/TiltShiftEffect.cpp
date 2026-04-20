#include "TiltShiftEffect.h"

namespace Fognitix::Effects {

TiltShiftEffect::TiltShiftEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TiltShiftEffect::typeId() const noexcept
{
    return "tilt_shift_effect";
}

void TiltShiftEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
