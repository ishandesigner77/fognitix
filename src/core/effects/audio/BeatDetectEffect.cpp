#include "BeatDetectEffect.h"

namespace Fognitix::Effects {

BeatDetectEffect::BeatDetectEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view BeatDetectEffect::typeId() const noexcept
{
    return "beat_detect_effect";
}

void BeatDetectEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
