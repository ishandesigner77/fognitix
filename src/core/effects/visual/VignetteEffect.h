#pragma once
#ifndef FOGNITIX_VIGNETTE_EFFECT_H
#define FOGNITIX_VIGNETTE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class VignetteEffect final : public EffectBase {
public:
    explicit VignetteEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
