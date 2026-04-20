#include "ShatterTransition.h"

namespace Fognitix::Effects {

ShatterTransition::ShatterTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ShatterTransition::typeId() const noexcept
{
    return "shatter_transition";
}

void ShatterTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
