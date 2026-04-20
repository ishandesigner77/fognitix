#include "PageTurnTransition.h"

namespace Fognitix::Effects {

PageTurnTransition::PageTurnTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view PageTurnTransition::typeId() const noexcept
{
    return "page_turn_transition";
}

void PageTurnTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
