#pragma once
#ifndef FOGNITIX_VOICE_ENHANCE_EFFECT_H
#define FOGNITIX_VOICE_ENHANCE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class VoiceEnhanceEffect final : public EffectBase {
public:
    explicit VoiceEnhanceEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
