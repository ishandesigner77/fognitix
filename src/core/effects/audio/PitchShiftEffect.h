#pragma once
#ifndef FOGNITIX_PITCH_SHIFT_EFFECT_H
#define FOGNITIX_PITCH_SHIFT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class PitchShiftEffect final : public EffectBase {
public:
    explicit PitchShiftEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
