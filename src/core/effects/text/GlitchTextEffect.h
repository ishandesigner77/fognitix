#pragma once
#ifndef FOGNITIX_GLITCH_TEXT_EFFECT_H
#define FOGNITIX_GLITCH_TEXT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class GlitchTextEffect final : public EffectBase {
public:
    explicit GlitchTextEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
