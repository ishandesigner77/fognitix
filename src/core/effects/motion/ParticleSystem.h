#pragma once
#ifndef FOGNITIX_PARTICLE_SYSTEM_H
#define FOGNITIX_PARTICLE_SYSTEM_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ParticleSystem final : public EffectBase {
public:
    explicit ParticleSystem(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
