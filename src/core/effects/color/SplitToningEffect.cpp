#include "SplitToningEffect.h"

namespace Fognitix::Effects {

SplitToningEffect::SplitToningEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view SplitToningEffect::typeId() const noexcept
{
    return "split_toning_effect";
}

void SplitToningEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
