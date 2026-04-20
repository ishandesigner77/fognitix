#pragma once
#ifndef FOGNITIX_NOISE_REDUCTION_EFFECT_H
#define FOGNITIX_NOISE_REDUCTION_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class NoiseReductionEffect final : public EffectBase {
public:
    explicit NoiseReductionEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
