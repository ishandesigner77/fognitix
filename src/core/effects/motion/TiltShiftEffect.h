#pragma once
#ifndef FOGNITIX_TILT_SHIFT_EFFECT_H
#define FOGNITIX_TILT_SHIFT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TiltShiftEffect final : public EffectBase {
public:
    explicit TiltShiftEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
