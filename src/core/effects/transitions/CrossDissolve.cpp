#include "CrossDissolve.h"

namespace Fognitix::Effects {

CrossDissolve::CrossDissolve(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view CrossDissolve::typeId() const noexcept
{
    return "cross_dissolve";
}

void CrossDissolve::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
