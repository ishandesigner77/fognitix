#include "TransitionBase.h"

namespace Fognitix::Effects {

TransitionBase::TransitionBase(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TransitionBase::typeId() const noexcept
{
    return "transition_base";
}

void TransitionBase::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
