#pragma once
#ifndef FOGNITIX_MOTION_BLUR_EFFECT_H
#define FOGNITIX_MOTION_BLUR_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class MotionBlurEffect final : public EffectBase {
public:
    explicit MotionBlurEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
