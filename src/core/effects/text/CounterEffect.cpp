#include "CounterEffect.h"

namespace Fognitix::Effects {

CounterEffect::CounterEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view CounterEffect::typeId() const noexcept
{
    return "counter_effect";
}

void CounterEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
