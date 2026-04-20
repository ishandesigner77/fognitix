#include "LiquidTextEffect.h"

namespace Fognitix::Effects {

LiquidTextEffect::LiquidTextEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LiquidTextEffect::typeId() const noexcept
{
    return "liquid_text_effect";
}

void LiquidTextEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
