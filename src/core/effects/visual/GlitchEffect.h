#pragma once
#ifndef FOGNITIX_GLITCH_EFFECT_H
#define FOGNITIX_GLITCH_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class GlitchEffect final : public EffectBase {
public:
    explicit GlitchEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
