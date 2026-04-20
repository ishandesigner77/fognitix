#pragma once
#ifndef FOGNITIX_PHYSICS_ENGINE_H
#define FOGNITIX_PHYSICS_ENGINE_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class PhysicsEngine final : public EffectBase {
public:
    explicit PhysicsEngine(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
