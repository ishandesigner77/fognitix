#include "StabilizerEffect.h"

namespace Fognitix::Effects {

StabilizerEffect::StabilizerEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view StabilizerEffect::typeId() const noexcept
{
    return "stabilizer_effect";
}

void StabilizerEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
