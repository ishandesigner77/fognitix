#include "LUTEffect.h"

namespace Fognitix::Effects {

LUTEffect::LUTEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view LUTEffect::typeId() const noexcept
{
    return "l_u_t_effect";
}

void LUTEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
