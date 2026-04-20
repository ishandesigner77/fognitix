#include "PhysicsEngine.h"

namespace Fognitix::Effects {

PhysicsEngine::PhysicsEngine(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view PhysicsEngine::typeId() const noexcept
{
    return "physics_engine";
}

void PhysicsEngine::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
