#include "ContrastEffect.h"

namespace Fognitix::Effects {

ContrastEffect::ContrastEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ContrastEffect::typeId() const noexcept
{
    return "contrast_effect";
}

void ContrastEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
