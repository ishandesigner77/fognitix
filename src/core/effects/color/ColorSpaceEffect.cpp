#include "ColorSpaceEffect.h"

namespace Fognitix::Effects {

ColorSpaceEffect::ColorSpaceEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ColorSpaceEffect::typeId() const noexcept
{
    return "color_space_effect";
}

void ColorSpaceEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
