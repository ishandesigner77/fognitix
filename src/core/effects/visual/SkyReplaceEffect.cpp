#include "SkyReplaceEffect.h"

namespace Fognitix::Effects {

SkyReplaceEffect::SkyReplaceEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view SkyReplaceEffect::typeId() const noexcept
{
    return "sky_replace_effect";
}

void SkyReplaceEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
