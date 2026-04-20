#include "ColorWheelsEffect.h"

namespace Fognitix::Effects {

ColorWheelsEffect::ColorWheelsEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ColorWheelsEffect::typeId() const noexcept
{
    return "color_wheels_effect";
}

void ColorWheelsEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
