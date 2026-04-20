#pragma once
#ifndef FOGNITIX_CAMERA_SHAKE_EFFECT_H
#define FOGNITIX_CAMERA_SHAKE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class CameraShakeEffect final : public EffectBase {
public:
    explicit CameraShakeEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
