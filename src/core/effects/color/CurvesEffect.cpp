#include "CurvesEffect.h"

namespace Fognitix::Effects {

CurvesEffect::CurvesEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view CurvesEffect::typeId() const noexcept
{
    return "curves_effect";
}

void CurvesEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
