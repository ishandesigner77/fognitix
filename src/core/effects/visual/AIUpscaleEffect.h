#pragma once
#ifndef FOGNITIX_A_I_UPSCALE_EFFECT_H
#define FOGNITIX_A_I_UPSCALE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class AIUpscaleEffect final : public EffectBase {
public:
    explicit AIUpscaleEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
