#pragma once
#ifndef FOGNITIX_BEAT_DETECT_EFFECT_H
#define FOGNITIX_BEAT_DETECT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class BeatDetectEffect final : public EffectBase {
public:
    explicit BeatDetectEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
