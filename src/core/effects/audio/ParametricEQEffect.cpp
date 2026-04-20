#include "ParametricEQEffect.h"

namespace Fognitix::Effects {

ParametricEQEffect::ParametricEQEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ParametricEQEffect::typeId() const noexcept
{
    return "parametric_e_q_effect";
}

void ParametricEQEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
