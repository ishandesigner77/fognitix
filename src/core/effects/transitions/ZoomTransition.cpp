#include "ZoomTransition.h"

namespace Fognitix::Effects {

ZoomTransition::ZoomTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ZoomTransition::typeId() const noexcept
{
    return "zoom_transition";
}

void ZoomTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
