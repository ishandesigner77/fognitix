#include "ColorMatchEffect.h"

namespace Fognitix::Effects {

ColorMatchEffect::ColorMatchEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ColorMatchEffect::typeId() const noexcept
{
    return "color_match_effect";
}

void ColorMatchEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
