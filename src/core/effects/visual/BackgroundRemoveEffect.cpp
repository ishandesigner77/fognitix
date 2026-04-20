#include "BackgroundRemoveEffect.h"

namespace Fognitix::Effects {

BackgroundRemoveEffect::BackgroundRemoveEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view BackgroundRemoveEffect::typeId() const noexcept
{
    return "background_remove_effect";
}

void BackgroundRemoveEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
