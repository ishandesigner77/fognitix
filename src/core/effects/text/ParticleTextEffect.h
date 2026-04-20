#pragma once
#ifndef FOGNITIX_PARTICLE_TEXT_EFFECT_H
#define FOGNITIX_PARTICLE_TEXT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ParticleTextEffect final : public EffectBase {
public:
    explicit ParticleTextEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
