#include "ParticleSystem.h"

namespace Fognitix::Effects {

ParticleSystem::ParticleSystem(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ParticleSystem::typeId() const noexcept
{
    return "particle_system";
}

void ParticleSystem::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
