#include "ColorBalanceEffect.h"

namespace Fognitix::Effects {

ColorBalanceEffect::ColorBalanceEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ColorBalanceEffect::typeId() const noexcept
{
    return "color_balance_effect";
}

void ColorBalanceEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
