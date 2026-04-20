#include "WhipPanTransition.h"

namespace Fognitix::Effects {

WhipPanTransition::WhipPanTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view WhipPanTransition::typeId() const noexcept
{
    return "whip_pan_transition";
}

void WhipPanTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
