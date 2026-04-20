#include "VoiceEnhanceEffect.h"

namespace Fognitix::Effects {

VoiceEnhanceEffect::VoiceEnhanceEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view VoiceEnhanceEffect::typeId() const noexcept
{
    return "voice_enhance_effect";
}

void VoiceEnhanceEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
