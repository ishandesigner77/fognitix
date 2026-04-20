#include "ParticleTextEffect.h"

namespace Fognitix::Effects {

ParticleTextEffect::ParticleTextEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ParticleTextEffect::typeId() const noexcept
{
    return "particle_text_effect";
}

void ParticleTextEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
