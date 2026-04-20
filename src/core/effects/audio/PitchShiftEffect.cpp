#include "PitchShiftEffect.h"

namespace Fognitix::Effects {

PitchShiftEffect::PitchShiftEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view PitchShiftEffect::typeId() const noexcept
{
    return "pitch_shift_effect";
}

void PitchShiftEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
